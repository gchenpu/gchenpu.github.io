---
resources:
  - test_tracer_eq_local.ipynb
---

## Wave Activity

**Codes** for computing local wave activity (LWA) described in [Chen et al. 2015](/publication/2015-12-1-Chen2015.qmd). A simplified version of the LWA algorithm is illustrated [here](./Wang-2020-NCC-SI.pdf). 

- Matlab code
    * [tracer_eq_1var_2d_local3.m](./tracer_eq_1var_2d_local3.m): subroutine to compute local wave activity
    * [test_tracer_eq_local.m](./test_tracer_eq_local.m): sample script to run the local wave activity code with idealized wave perturbations

- Python code
    * [tracer_eq_1var_2d_local4.py](./tracer_eq_1var_2d_local4.py): subroutine to compute local wave activity
    * [test_tracer_eq_local.ipynb](./test_tracer_eq_local.html) (<a href="#" download="test_tracer_eq_local.ipynb" onclick="this.href='/files/LWA/test_tracer_eq_local.ipynb'">download .ipynb</a>): sample jupyter notebook script to run the local wave activity code with idealized wave perturbations

- Fortran 90
    * Example to compute zonal mean wave activity: [compute_wave_activity-1.f90](./compute_wave_activity-1.f90) and [compute_sort.f90](./compute_sort.f90)

**Example** of LWA for European summer heat waves in 2003:
![](./AsAn_aug2003.gif)
