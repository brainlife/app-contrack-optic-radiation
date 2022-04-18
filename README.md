[![Abcdspec-compliant](https://img.shields.io/badge/ABCD_Spec-v1.1-green.svg)](https://github.com/brain-life/abcd-spec)
[![Run on Brainlife.io](https://img.shields.io/badge/Brainlife-brainlife.app.252-blue.svg)](https://doi.org/https://doi.org/10.25663/brainlife.app.252)

# Track The Human Optic RAdiation (THORA): Contrack - Eccentricity

This app will This app will track the optic radiation using Contrack (Sherbondy et al, 2009). Specifically, this app will track the optic radiation and then segment it into multiple bundles based on the visual property of eccentricity derived from population receptive field (prf) mapping. This app takes a dtiinit, anat/t1w, rois, prf, mask (tissue type), and freesurfer datatypes and outputs a track/tck and wmc datatype.

### Authors

- Brad Caron (bacaron@utexas.edu)

### Contributors

- Soichi Hayashi (shayashi@iu.edu)

### Funding Acknowledgement

brainlife.io is publicly funded and for the sustainability of the project it is helpful to Acknowledge the use of the platform. We kindly ask that you acknowledge the funding below in your publications and code reusing this code.

[![NSF-BCS-1734853](https://img.shields.io/badge/NSF_BCS-1734853-blue.svg)](https://nsf.gov/awardsearch/showAward?AWD_ID=1734853)
[![NSF-BCS-1636893](https://img.shields.io/badge/NSF_BCS-1636893-blue.svg)](https://nsf.gov/awardsearch/showAward?AWD_ID=1636893)
[![NSF-ACI-1916518](https://img.shields.io/badge/NSF_ACI-1916518-blue.svg)](https://nsf.gov/awardsearch/showAward?AWD_ID=1916518)
[![NSF-IIS-1912270](https://img.shields.io/badge/NSF_IIS-1912270-blue.svg)](https://nsf.gov/awardsearch/showAward?AWD_ID=1912270)
[![NIH-NIBIB-R01EB029272](https://img.shields.io/badge/NIH_NIBIB-R01EB029272-green.svg)](https://grantome.com/grant/NIH/R01-EB029272-01)

### Citations

We kindly ask that you cite the following articles when publishing papers and code using this code.

1. Avesani, P., McPherson, B., Hayashi, S. et al. The open diffusion data derivatives, brain data upcycling via integrated publishing of derivatives and reproducible open cloud services. Sci Data 6, 69 (2019). https://doi.org/10.1038/s41597-019-0073-y

2. Sherbondy AJ, Dougherty RF, Ben-Shachar M, Napel S, Wandell BA. ConTrack: finding the most likely pathways between brain regions using diffusion tractography. J Vis. 2008;8(9):1-16. Published 2008 Jul 29. doi:10.1167/8.9.15

3. Shumpei Ogawa, Hiromasa Takemura, Hiroshi Horiguchi, Masahiko Terao, Tomoki Haji, Franco Pestilli, Jason D. Yeatman, Hiroshi Tsuneoka, Brian A. Wandell, Yoichiro Masuda; White Matter Consequences of Retinal Receptor and Ganglion Cell Damage. Invest. Ophthalmol. Vis. Sci. 2014;55(10):6976-6986. doi: https://doi.org/10.1167/iovs.14-14737.

4. Yoshimine S, Ogawa S, Horiguchi H, Terao M, Miyazaki A, Matsumoto K, Tsuneoka H, Nakano T, Masuda Y, Pestilli F. Age-related macular degeneration affects the optic radiation white matter projecting to locations of retinal damage. Brain Struct Funct. 2018 Nov;223(8):3889-3900. doi: 10.1007/s00429-018-1702-5. Epub 2018 Jun 27. PMID: 29951918.

#### MIT Copyright (c) 2020 brainlife.io The University of Texas at Austin and Indiana University

## Running the App

### On Brainlife.io

You can submit this App online at [https://doi.org/https://doi.org/10.25663/brainlife.app.252](https://doi.org/https://doi.org/10.25663/brainlife.app.252) via the 'Execute' tab.

### Running Locally (on your machine)

1. git clone this repo

2. Inside the cloned directory, create `config.json` with something like the following content with paths to your input files.

```json
{
	"dtiinit": "/input/dtiinit",
	"t1": "/input/t1/t1.nii.gz",
	"rois": "/input/rois/rois",
	"eccentricity": "/input/prf/eccentricity.nii.gz",
	"varea": "/input/prf/varea.nii.gz",
	"mask": "/input/5tt/mask.nii.gz",
	"freesurfer": "/input/freesurfer/output",
	"count": 200,
	"minnodes": 10,
	"stepsize": 1,
	"seed_roi": "008109",
	"term_roi": "v1",
	"MinDegree": "0 15 30",
	"MaxDegree": "3 30 90"
}
```

### Sample Datasets

You can download sample datasets from Brainlife using [Brainlife CLI](https://github.com/brain-life/cli).

```
npm install -g brainlife
bl login
mkdir input
bl dataset download
```

3. Launch the App by executing 'main'

```bash
./main
```

## Output

The main output of this App is a track/tck datatype containing the tractogram of the optic radiations and a wmc datatype containing the streamline classification information.

#### Product.json

The secondary output of this app is `product.json`. This file allows web interfaces, DB and API calls on the results of the processing.

### Dependencies

This App only requires [singularity](https://www.sylabs.io/singularity/) to run. If you don't have singularity, you will need to install following dependencies.   

- matlab: https://www.mathworks.com/products/matlab.html
- vistasoft: https://github.com/vistalab/vistasoft
- https://github.com/francopestilli/encode
- jsonlab: https://github.com/fangq/jsonlab
- afq: https://github.com/yeatmanlab/AFQ
- wma_tools: https://github.com/DanNBullock/wma_tools

#### MIT Copyright (c) 2020 brainlife.io The University of Texas at Austin and Indiana University
