/* PVTypes.h */

#import <math.h>

enum {PV_AbsDynamic=0,  PV_RelDynamic, PV_AbsTempo, PV_RelTempo, PV_Articulation, PV_Custom_1D, PV_Custom_2D};

/* Absolute Dynamics */
enum {PV_ppppp=0, PV_mpppp, PV_pppp, PV_mppp, PV_ppp, PV_mpp, PV_pp, PV_mp, PV_p, PV_mf, PV_f, PV_mff, PV_ff, PV_mfff, PV_fff, PV_mffff, PV_ffff, PV_mfffff, PV_fffff};
#define ABSDYN_RANGE 19

/* Relative Dynamics */
enum {PV_moltodim=0, PV_dim, PV_cresc, PV_moltocresc};
#define RELDYN_RANGE 4

/* Relative Tempo */
enum {PV_moltoritard=0, PV_ritard, PV_accel, PV_moltoaccel, PV_fermata, PV_fermatashift, PV_fermatadelay};
#define RELTPO_RANGE 7

/* Articulation */
enum {PV_moltostaccato=0, PV_staccato, PV_nonlegato, PV_legato, PV_moltolegato};
#define ARTI_RANGE 5


#define  EPSILON  0.0001



double dynAdjust(double, double, double, double);

