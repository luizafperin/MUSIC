// Copyright 2018 @ Chun Shen

#include "eos_gp.h"
#include "util.h"

#include <sstream>
#include <fstream>
#include <cmath>
#include <gsl/gsl_spline.h>
#include <gsl/gsl_interp.h>

using std::stringstream;
using std::string;

EOS_gp::EOS_gp(const int eos_id_in) : eos_id(eos_id_in) {
    set_EOS_id(eos_id);
    set_number_of_tables(0);
    set_eps_max(1e5);
    set_flag_muB(false);
    set_flag_muS(false);
    set_flag_muQ(false);
}


void EOS_gp::initialize_eos() {
    // read the lattice EOS pressure, temperature, and 
    music_message.info("reading EOS_gp");
    
    auto envPath = get_hydro_env_path();
    music_message << "from path " << envPath.c_str() << "/EOS/EOS-gp";
    music_message.flush("info");
    
    set_number_of_tables(1);
    resize_table_info_arrays();

    int ntables = get_number_of_tables();

    //string eos_file_string_array[2] = {"1"};
    pressure_tb    = new double** [ntables];
    temperature_tb = new double** [ntables];
    cs2_tb = new double** [ntables];
    entropy_tb = new double** [ntables];
    energy_tb = new double** [ntables];

    for (int itable = 0; itable < ntables; itable++) {
    	//music_message << "reading table " << itable;
    	//music_message.flush("info");
    	
        std::ifstream eos_file(envPath + "/EOS/EOS-gp/constrained/l400_s15/eos_w_s0_l400_s15.dat");
        music_message << "file from path " << envPath.c_str() << "/EOS/EOS-gp/constrained/l400_s15/eos_w_s0_l400_s15.dat \n";

        //fixed baryon number/density -> not a grid in energy and density  
        nb_length[itable] = 1;
        
        //reads first line with number of energy points
        eos_file >> e_length[itable];
        music_message << "e_length[itable] " << e_length[itable];
        music_message.flush("info");

        // skip the header in the file        
        string dummy;
        std::getline(eos_file, dummy);
        
        // read pressure, temperature and chemical potential values from the file and store it in each array
        
        // allocate memory for EOS arrays
        //mtx_malloc allocates and initializes a matrix of size nb_length x e_length
        pressure_tb[itable] = Util::mtx_malloc(nb_length[itable],
                                               e_length[itable]);
                                               
        temperature_tb[itable] = Util::mtx_malloc(nb_length[itable],
                                                  e_length[itable]);
                                                  
        cs2_tb[itable] = Util::mtx_malloc(nb_length[itable],
                                           e_length[itable]);
                                           
        entropy_tb[itable] = Util::mtx_malloc(nb_length[itable],
                                           e_length[itable]);
                                           
        energy_tb[itable] = Util::mtx_malloc(nb_length[itable],
                                           e_length[itable]);
        
            
        string line;
        
        for (int ii = 0; ii < e_length[itable]; ii++) {

            getline(eos_file, line);
            std::istringstream iss(line);
            double energy, temperature, pressure, cs2, entropy;
            
            if (!(iss >> energy >> temperature >> pressure >> cs2 >> entropy)) {
        	music_message << "Error parsing line " << ii << ": " << line;
        	music_message.flush("info");
        	break;
            }

/*             if(ii<=1){ 
                music_message << "temp " << temperature << " energy " << energy;
                music_message.flush("info");
            } */
            
            temperature_tb[itable][0][ii] = temperature/ Util::hbarc;    // 1/fm

            pressure_tb[itable][0][ii] = pressure/ Util::hbarc; // 1/fm^4
            
            cs2_tb[itable][0][ii] = cs2; //dimensionless
            
            entropy_tb[itable][0][ii] = entropy; //1/fm^3
            
            energy_tb[itable][0][ii] = energy/ Util::hbarc; // 1/fm^4
            
        }

         // Initialize splines for all properties
        /* const int N_e = e_length[itable];
        const double *xe = energy_tb[itable][0];
        
        // Temperature spline
        temperature_spline_cache.push_back(gsl_spline_alloc(gsl_interp_linear, N_e));
        temperature_accel_cache.push_back(gsl_interp_accel_alloc());
        gsl_spline_init(temperature_spline_cache[itable], xe, temperature_tb[itable][0], N_e);
        
        // Pressure spline
        pressure_spline_cache.push_back(gsl_spline_alloc(gsl_interp_linear, N_e));
        pressure_accel_cache.push_back(gsl_interp_accel_alloc());
        gsl_spline_init(pressure_spline_cache[itable], xe, pressure_tb[itable][0], N_e);
        
        // cs2 spline
        cs2_spline_cache.push_back(gsl_spline_alloc(gsl_interp_linear, N_e));
        cs2_accel_cache.push_back(gsl_interp_accel_alloc());
        gsl_spline_init(cs2_spline_cache[itable], xe, cs2_tb[itable][0], N_e);
        
        // Entropy spline
        entropy_spline_cache.push_back(gsl_spline_alloc(gsl_interp_linear, N_e));
        entropy_accel_cache.push_back(gsl_interp_accel_alloc());
        gsl_spline_init(entropy_spline_cache[itable], xe, entropy_tb[itable][0], N_e); */ 
        
    }

    music_message.info("Done reading EOS.");
}


// Interpolations

double EOS_gp::p_e_func(double e, double rhob) const {
    return(get_dpOverde3(e, rhob));
}

void EOS_gp::get_pressure_with_gradients(
    double epsilon, double rhob, double &p, double &dpde, double &dpdrhob,
    double &cs2) const {
    // For EOS_gp, we have tabulated cs2 and can compute dpde from it
    // This avoids numerical differentiation issues that can occur in MaxSpeed
    p = get_pressure(epsilon, rhob);
    cs2 = get_cs2(epsilon, rhob);
    dpde = p_e_func(epsilon, rhob);
    
    // For zero rhob EOS (which EOS_gp uses), dpdrhob = 0
    // but we compute it for consistency with the base class signature
    dpdrhob = 0.0;  // EOS_gp is independent of rhob
}

//! This function returns the local temperature in [1/fm]
//! input local energy density eps [1/fm^4] and rhob [1/fm^3]
double EOS_gp::get_temperature(double e, double rhob) const {
    //double T = interpolate_spline(e, 0, temperature_spline_cache, 
    //                              temperature_accel_cache, temperature_tb);
    double T = interpolate1D_nonuniform(e, 0, energy_tb, temperature_tb, 7000.);
    return(std::max(Util::small_eps, T));
}

//! This function returns the local pressure in [1/fm^4]
//! the input local energy density [1/fm^4], rhob [1/fm^3]
double EOS_gp::get_pressure(double e, double rhob) const {
    //double f = interpolate_spline(e, 0, pressure_spline_cache,
    //                             pressure_accel_cache, pressure_tb);
    double f = interpolate1D_nonuniform(e, 0, energy_tb, pressure_tb, 200/Util::hbarc);
    return(std::max(Util::small_eps, f));
}

double EOS_gp::get_cs2(double e, double rhob) const {
    //double f = interpolate_spline(e, 0, cs2_spline_cache,
     //                             cs2_accel_cache, cs2_tb);
    double f = interpolate1D_nonuniform(e, 0, energy_tb, cs2_tb, 0.333);
    return(std::max(Util::small_eps, f));
}

double EOS_gp::get_entropy(double e, double rhob) const {
    //double f = interpolate_spline(e, 0, entropy_spline_cache,
    //                              entropy_accel_cache, entropy_tb);
    double f = interpolate1D_nonuniform(e, 0, energy_tb, entropy_tb, 1000.);
    return(std::max(Util::small_eps, f));
}

//keep this ones?

double EOS_gp::get_s2e(double s, double rhob) const {
    double e = get_s2e_finite_rhob(s, 0.0);
    return(e);
}

double EOS_gp::get_T2e(double T_in_GeV, double rhob) const {
    double e = get_T2e_finite_rhob(T_in_GeV, 0.0);
    return(e);
}

