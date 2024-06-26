#!/bin/bash 

get_batch_options() {
    local arguments=("$@")

    unset command_line_specified_study_folder
    unset command_line_specified_subj
    unset command_line_specified_run_local

    local index=0
    local numArgs=${#arguments[@]}
    local argument

    while [ ${index} -lt ${numArgs} ]; do
        argument=${arguments[index]}

        case ${argument} in
            --StudyFolder=*)
                command_line_specified_study_folder=${argument#*=}
                index=$(( index + 1 ))
                ;;
            --Subject=*)
                command_line_specified_subj=${argument#*=}
                index=$(( index + 1 ))
                ;;
            --runlocal)
                command_line_specified_run_local="TRUE"
                index=$(( index + 1 ))
                ;;
	    *)
		echo ""
		echo "ERROR: Unrecognized Option: ${argument}"
		echo ""
		exit 1
		;;
        esac
    done
}

get_batch_options "$@"

StudyFolder="/media/ubuntu/NCU/deng/Rawdata" #Location of Subject folders (named by subjectID)
Subjlist="sub-236 sub-237 sub-238 sub-239 sub-240 sub-241 sub-242 sub-243 sub-244 sub-245 sub-246 sub-559 sub-561 sub-562 sub-563" #Space delimited list of subject IDs
###sub-174 sub-184 sub-189sub-546 sub-547 sub-548 sub-549 sub-550 sub-551 sub-552 sub-553 sub-554 sub-555ub-542 sub-543 sub-544 sub-545sub-537 sub-538 sub-539 sub-540 sub-541sub-014 sub-015 sub-016 sub-017 sub-018 sub-019 sub-020sub-179 sub-180 sub-182 sub-183 sub-184 sub-185 sub-186 sub-187 sub-188 sub-189 sub-190 sub-191sub-181 sub-192 sub-193sub-400 sub-401 sub-402 sub-403 sub-404 sub-405 sub-406 sub-407 sub-408 sub-409 sub-410 sub-411 sub-412 sub-413 sub-414 sub-415 sub-416 sub-417 sub-418 sub-419 sub-420 sub-421 sub-422 sub-423 sub-424 sub-425 sub-426 sub-427 sub-428 sub-430 sub-431 sub-432 sub-433 sub-434 sub-435 sub-436 sub-437 sub-438 sub-439 sub-440 sub-441 sub-442 sub-443 sub-444 sub-445 sub-446 sub-447 sub-448 sub-449 sub-450sub-505 sub-202 sub-203 sub-204 sub-205 sub-206 sub-207 sub-208 sub-209 sub-210sub-506 sub-507 sub-508 sub-509 sub-510 sub-511 sub-512 sub-513 sub-514 sub-515sub-101 sub-102 sub-103 sub-104 sub-105 sub-106 sub-107 sub-108 sub-109 sub-110 sub-111 sub-112 sub-113 sub-114 sub-115 sub-116 sub-117 sub-118 sub-119 sub-120 sub-121 sub-122 sub-123 sub-124 sub-125 sub-126 sub-127 sub-128 sub-129 sub-130 sub-131 sub-132 sub-133 sub-134 sub-135 sub-136 sub-137 sub-138 sub-139 sub-140 sub-141 sub-142 sub-143 sub-144 sub-145 sub-146 sub-147 sub-148 sub-149 sub-150 sub-151 sub-152 sub-153 sub-154 sub-155 sub-156 sub-157 sub-158 sub-219 sub-220 sub-221 sub-222 sub-223 sub-224 sub-225 sub-226 sub-227 sub-228sub-530 sub-531 sub-532 sub-533 sub-534 sub-535 sub-536
#EnvironmentScript="${HOME}/projects/Pipelines/Examples/Scripts/SetUpHCPPipeline.sh" #Pipeline environment script
EnvironmentScript="/media/ubuntu//5a0ea278-2829-4adb-a52a-1ecb9f33a53b//home/chaw/projects/Pipelines/Examples/Scripts/SetUpHCPPipeline.sh"

if [ -n "${command_line_specified_study_folder}" ]; then
    StudyFolder="${command_line_specified_study_folder}"
fi

if [ -n "${command_line_specified_subj}" ]; then
    Subjlist="${command_line_specified_subj}"
fi

# Requirements for this script
#  installed versions of: FSL, Connectome Workbench (wb_command)
#  environment: HCPPIPEDIR, FSLDIR, CARET7DIR

#Set up pipeline environment variables and software
source ${EnvironmentScript}

# Log the originating call
echo "$@"

#if [ X$SGE_ROOT != X ] ; then
#    QUEUE="-q long.q"
    QUEUE="-q hcp_priority.q"
#fi

PRINTCOM=""
#PRINTCOM="echo"
#QUEUE="-q veryshort.q"


########################################## INPUTS ########################################## 

#Scripts called by this script do assume they run on the outputs of the FreeSurfer Pipeline

######################################### DO WORK ##########################################


for Subject in $Subjlist ; do
  echo $Subject

  #Input Variables
  SurfaceAtlasDIR="${HCPPIPEDIR_Templates}/standard_mesh_atlases"
  GrayordinatesSpaceDIR="${HCPPIPEDIR_Templates}/91282_Greyordinates"
  GrayordinatesResolutions="2" #Usually 2mm, if multiple delimit with @, must already exist in templates dir
  HighResMesh="164" #Usually 164k vertices
  LowResMeshes="32" #Usually 32k vertices, if multiple delimit with @, must already exist in templates dir
  SubcorticalGrayLabels="${HCPPIPEDIR_Config}/FreeSurferSubcorticalLabelTableLut.txt"
  FreeSurferLabels="${HCPPIPEDIR_Config}/FreeSurferAllLut.txt"
  ReferenceMyelinMaps="${HCPPIPEDIR_Templates}/standard_mesh_atlases/Conte69.MyelinMap_BC.164k_fs_LR.dscalar.nii"
  RegName="MSMSulc" #MSMSulc is recommended, if binary is not available use FS (FreeSurfer)
  
  if [ -n "${command_line_specified_run_local}" ] ; then
      echo "About to run ${HCPPIPEDIR}/PostFreeSurfer/PostFreeSurferPipeline.sh"
      queuing_command=""
  else
      echo "About to use fsl_sub to queue or run ${HCPPIPEDIR}/PostFreeSurfer/PostFreeSurferPipeline.sh"
      queuing_command="${FSLDIR}/bin/fsl_sub ${QUEUE}"
  fi

  ${queuing_command} ${HCPPIPEDIR}/PostFreeSurfer/PostFreeSurferPipeline.sh \
      --path="$StudyFolder" \
      --subject="$Subject" \
      --surfatlasdir="$SurfaceAtlasDIR" \
      --grayordinatesdir="$GrayordinatesSpaceDIR" \
      --grayordinatesres="$GrayordinatesResolutions" \
      --hiresmesh="$HighResMesh" \
      --lowresmesh="$LowResMeshes" \
      --subcortgraylabels="$SubcorticalGrayLabels" \
      --freesurferlabels="$FreeSurferLabels" \
      --refmyelinmaps="$ReferenceMyelinMaps" \
      --regname="$RegName" \
      --printcom=$PRINTCOM

  # The following lines are used for interactive debugging to set the positional parameters: $1 $2 $3 ...
  
   echo "set -- --path="$StudyFolder" \
      --subject="$Subject" \
      --surfatlasdir="$SurfaceAtlasDIR" \
      --grayordinatesdir="$GrayordinatesSpaceDIR" \
      --grayordinatesres="$GrayordinatesResolutions" \
      --hiresmesh="$HighResMesh" \
      --lowresmesh="$LowResMeshes" \
      --subcortgraylabels="$SubcorticalGrayLabels" \
      --freesurferlabels="$FreeSurferLabels" \
      --refmyelinmaps="$ReferenceMyelinMaps" \
      --regname="$RegName" \
      --printcom=$PRINTCOM"
      
   echo ". ${EnvironmentScript}"
done

