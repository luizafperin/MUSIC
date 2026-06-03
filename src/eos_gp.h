// Copyright 2018 @ Chun Shen

#ifndef SRC_EOS_gp
#define SRC_EOS_gp

#include "eos_base.h"

class EOS_gp : public EOS_base {
 private:
    const int eos_id;
    int l;
    int sigma;
    int T_sw;
    std::string eos_type;
    std::string sample;
    std::string gp_type;

 public:
    EOS_gp(const int eos_id_in);
    EOS_gp(const int eos_id_in, int l_in, int sigma_in, int T_sw_in,
           const std::string &eos_type_in, const std::string &sample_in, const std::string &gp_type);

    void initialize_eos();
    double p_e_func       (double e, double rhob) const;
    double get_temperature(double e, double rhob) const;
    double get_pressure   (double e, double rhob) const;
    double get_entropy    (double e, double rhob) const;
    double get_cs2        (double e, double rhob) const;
    double get_s2e        (double s, double rhob) const;
    double get_T2e        (double T, double rhob) const;
    
    void get_pressure_with_gradients(
        double epsilon, double rhob, double &p, double &dpde, double &dpdrhob,
        double &cs2) const override;

    void check_eos() const {check_eos_no_muB();}
};

#endif  // SRC_EOS_gp
