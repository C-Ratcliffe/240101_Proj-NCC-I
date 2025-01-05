# Functional analysis
while true
do
	echo Choose option:
	echo
	echo 1. Package install
	echo 2. fMRIprep
	echo 3. Skip functional analysis
	echo
	read "funcselect?Selection (1/3): "

	if [[ $funcselect == 1 ]]
	# Package install
	then
		python3 -m pip install fmriprep-docker
	
	elif [[ $funcselect == 2 ]]
	# fmri preprocessing analysis
	then
		open -a Docker
		fmridir=${derivdir}fmriprep/
		workdir=${fmridir}workdata/
		fsdir=${derivdir}freesurfer-7.4.1/
		fmrifsdir=${fmridir}sourcedata/freesurfer/
		declare -a subs=('906' '907' '908' '909' '910' '911')
		mkdir -p $workdir $fmrifsdir
		# fMRIprep
		for sub in ${subs[@]}
		do
			if [[ ! -e ${fmrifsdir}fsaverage ]]
			then
				cp -r ~/freesurfer/subjects/fsaverage ${fmrifsdir}fsaverage
			fi
			cp -r ${fsdir}sub-${sub} ${fmrifsdir}sub-${sub}
			#fmriprep-docker $rawdir $derivdir --participant-label $sub --fs-license-file ~/freesurfer/license.txt --use-syn-sdc --ignore fieldmaps -w $workdir --output-spaces T1w MNI152NLin2009cAsym
			fmriprep-docker $rawdir $fmridir --participant-label $sub --fs-license-file ~/freesurfer/license.txt -w $workdir --output-spaces T1w MNI152NLin2009cAsym
			rm -r ${fmrifsdir}sub-${sub}
		done
	elif [[ $funcselect == 3 ]]
	# Fucntional analysis is skipped
	then
		echo Functional analysis skipped.
		break

	else
		echo Invalid selection.
	fi
done