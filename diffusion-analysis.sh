# Diffusion Analysis
while true
do
	echo Choose option:
	echo
	echo 1. Package install
	echo 2. Fixel-based analysis
	echo 3. TractSeg
	echo 4. Statistics
	echo 5. Images
	echo 6. Skip diffusion analysis
	echo
	read "diffselect?Selection (1/6): "
	tsdir=${derivdir}tractseg/
	fbadir=${derivdir}fba/
	groupdir=${fbadir}group/
	templatedir=${fbadir}template/
	indir=${fbadir}input/
	tractseg_wmdir=${tsdir}template/
	template_wmfod=${templatedir}wmfod-template.mif
	bundledir=${templatedir}roi/bundles/
	statsdir=${templatedir}stats/norm/
	
	if [[ $diffselect == 1 ]]
	# Package install
	then
		# mrtrix3 - macOS
		# install xcode
		brew install qt5
		brew install eigen
		brew install pkg-config
		export PATH=`brew --prefix`/opt/qt5/bin:$PATH
		brew install libtiff
		brew install fftw
		brew install libpng
		git clone https://github.com/MRtrix3/mrtrix3.git
		cd mrtrix3
		./configure
		./build
		cd ~
		# mrtrix3tissue - macOS
		git clone https://github.com/3Tissue/MRtrix3Tissue.git MRtrix3Tissue
		cd MRtrix3Tissue
		git clone https://gitlab.com/libeigen/eigen.git
		cd eigen
		git checkout 3.3.9
		cd ~/MRtrix3Tissue
		EIGEN_CFLAGS="-isystem $(pwd)/eigen" ./configure
		./build
		./set_path ~/.zprofile
		# ANTS - macOS
		git clone https://github.com/ANTsX/ANTs.git
		mkdir build install
		cd build
		cmake -DCMAKE_INSTALL_PREFIX=~/ANTS2.5 ../ANTs 2>&1 | tee cmake.log
		make -j 4 2>&1 | tee build.log
		cd ANTS-build
		make install 2>&1 | tee install.log
		setenv PATH ~/ANTs-2.5/bin:$PATH
		# TractSeg - macOS
		cd ~/
		mkdir tractseg
		brew install pyenv
		pyenv install 3.6.15
		pyenv local 3.6.15
		pyenv exec python3.6 -m venv tractseg
		source tractseg/bin/activate
		pip install torch
		pip install packaging
		pip install TractSeg

	elif [[ $diffselect == 2 ]]
	# Fixel-based analysis
	then
		declare -a templatesubs=('sub-901' 'sub-902' 'sub-903' 'sub-904' 'sub-905' 'sub-907' 'sub-909' 'sub-910' 'sub-911' 'sub-930' 'sub-931' 'sub-932' 'sub-933' 'sub-934' 'sub-935' 'sub-936' 'sub-937' 'sub-938')
		mkdir -p ${templatedir}fc/ ${templatedir}logfc/ ${templatedir}fdc/ ${templatedir}tracks/ $bundledir $statsdir
		while true
		do
			echo Choose FBA action:
			echo
			echo 1. Data organisation and preprocessing
			echo 2. Template generation
			echo 3. Fixel and tensor estimation
			echo 4. Whole brain connectivity
			echo 5. Skip FBA
			echo
			read "fbaselect?Selection (1/5): "

			if [[ $fbaselect == 1 ]]
			# Data organisation and preprocessing
			then
				# Shell setup
				export FREESURFER_HOME=~/freesurfer
				source $FREESURFER_HOME/SetUpFreeSurfer.sh				
				mkdir -p $groupdir $indir
				for subpath in ${rawdir}sub-*
				do
					subname=${subpath##*/rawdata/}
					sub=${indir}${subname}/${subname}
					mkdir -p ${indir}${subname}/
					if [ -e ${subpath}/dwi/${subname}_dir-AP_dwi.bvec ]
					then
						mrconvert -fslgrad ${subpath}/dwi/${subname}_dir-AP_dwi.bvec ${subpath}/dwi/${subname}_dir-AP_dwi.bval ${subpath}/dwi/${subname}_dir-AP_dwi.nii.gz ${sub}_dwi.mif
						mrconvert -fslgrad ${subpath}/dwi/${subname}_dir-PA_dwi.bvec ${subpath}/dwi/${subname}_dir-PA_dwi.bval ${subpath}/dwi/${subname}_dir-PA_dwi.nii.gz  ${sub}_dwi-rev.mif
						mrconvert ${sub}_dwi.mif -coord 3 0 -axes 0,1,2 ${sub}_dir-AP_dwi.mif
						mrconvert ${sub}_dwi-rev.mif -coord 3 0 -axes 0,1,2 ${sub}_dir-PA_dwi.mif
						rm ${sub}_dwi-rev.mif
						dwidenoise ${sub}_dwi.mif ${sub}_dwi_denoised.mif
						mrdegibbs ${sub}_dwi_denoised.mif ${sub}_dwi_unringed.mif -axes 0,1
						mrcat ${sub}_dir-AP_dwi.mif ${sub}_dir-PA_dwi.mif ${sub}_acq-pair_dwi.mif -axis 3
						dwifslpreproc ${sub}_dwi_unringed.mif ${sub}_dwi_preproc.mif -rpe_pair -se_epi ${sub}_acq-pair_dwi.mif -pe_dir AP -align_seepi -eddy_options " --slm=linear"
					elif [ -e ${subpath}/dwi/${subname}_dir-LR_dwi.bvec ]
					then
						mrconvert -fslgrad ${subpath}/dwi/${subname}_dir-LR_dwi.bvec ${subpath}/dwi/${subname}_dir-LR_dwi.bval ${subpath}/dwi/${subname}_dir-LR_dwi.nii.gz ${sub}_dir-LR_dwi.mif
						mrconvert -fslgrad ${subpath}/dwi/${subname}_dir-RL_dwi.bvec ${subpath}/dwi/${subname}_dir-RL_dwi.bval ${subpath}/dwi/${subname}_dir-RL_dwi.nii.gz ${sub}_dir-RL_dwi.mif
						mrcat ${sub}_dir-LR_dwi.mif ${sub}_dir-RL_dwi.mif ${sub}_dwi.mif -axis 3
						rm ${sub}_dir-LR_dwi.mif ${sub}_dir-RL_dwi.mif
						dwidenoise ${sub}_dwi.mif ${sub}_dwi_denoised.mif
						mrdegibbs ${sub}_dwi_denoised.mif ${sub}_dwi_unringed.mif -axes 0,1
						dwifslpreproc ${sub}_dwi_unringed.mif ${sub}_dwi_preproc.mif -rpe_all -pe_dir LR 
					fi
					dwibiascorrect ants ${sub}_dwi_preproc.mif ${sub}_dwi_unbiased.mif
					mrgrid ${sub}_dwi_unbiased.mif regrid -vox 1.25 ${sub}_dwi_upsampled.mif
					#mri_synthstrip
					mrconvert ${sub}_dwi_upsampled.mif ${sub}_dwi_upsampled.nii.gz
					fslmaths ${sub}_dwi_upsampled.nii.gz -Tmean ${sub}_dwi_upsampled_mean.nii.gz
					mri_synthstrip -i ${sub}_dwi_upsampled_mean.nii.gz -m ${sub}_dwi_upsampled_mean_mask.nii.gz
					mrconvert ${sub}_dwi_upsampled_mean_mask.nii.gz ${sub}_dwi_upsampled-mask.mif
					if [ -e ${subpath}/dwi/${subname}_dir-AP_dwi.bvec ]
					then
						dwi2response dhollander ${sub}_dwi_upsampled.mif ${sub}_dwi_response-nimwm.txt ${sub}_dwi_response-nimgm.txt ${sub}_dwi_response-nimcsf.txt -mask ${sub}_dwi_upsampled-mask.mif
					elif [ -e ${subpath}/dwi/${subname}_dir-LR_dwi.bvec ]
					then
						dwi2response dhollander ${sub}_dwi_upsampled.mif ${sub}_dwi_response-hcpwm.txt ${sub}_dwi_response-hcpgm.txt ${sub}_dwi_response-hcpcsf.txt -mask ${sub}_dwi_upsampled-mask.mif
					fi
				done

					# delete directories for the subjects which haven't processed fully
				for subpath in ${indir}sub*
				do
					if [ ! -e ${subpath}/*_dwi_upsampled.mif ]
					then
						rm -r ${subpath}
					fi
				done

			elif [[ $fbaselect == 2 ]]
			# Template generation
			then
				mkdir -p ${templatedir}fod_input/ ${templatedir}mask_input/ ${templatedir}fd/
				responsemean ${indir}sub*/*nimwm.txt ${groupdir}nimhans_average_response-wm.txt
				responsemean ${indir}sub*/*nimgm.txt ${groupdir}nimhans_average_response-gm.txt
				responsemean ${indir}sub*/*nimcsf.txt ${groupdir}nimhans_average_response-csf.txt
				responsemean ${indir}sub*/*hcpwm.txt ${groupdir}hcp_average_response-wm.txt
				responsemean ${indir}sub*/*hcpgm.txt ${groupdir}hcp_average_response-gm.txt
				responsemean ${indir}sub*/*hcpcsf.txt ${groupdir}hcp_average_response-csf.txt

				for subpath in ${indir}sub*
				do
					subname=${subpath##*/input/}
					sub=${subpath}/${subname}
					##msmt
					if [ -e ${sub}_dwi_response-nimwm.txt ]
					then
						dwi2fod msmt_csd ${sub}_dwi_upsampled.mif ${groupdir}nimhans_average_response-wm.txt ${sub}_wmfod.mif ${groupdir}nimhans_average_response-gm.txt ${sub}_gmfod.mif ${groupdir}nimhans_average_response-csf.txt ${sub}_csf.mif -mask ${sub}_dwi_upsampled-mask.mif
					elif [ -e ${sub}_dwi_response-hcpwm.txt ]
					then
						dwi2fod msmt_csd ${sub}_dwi_upsampled.mif ${groupdir}hcp_average_response-wm.txt ${sub}_wmfod.mif ${groupdir}hcp_average_response-gm.txt ${sub}_gmfod.mif ${groupdir}hcp_average_response-csf.txt ${sub}_csf.mif -mask ${sub}_dwi_upsampled-mask.mif
					else 
						echo No response function found.
					fi
					mtnormalise ${sub}_wmfod.mif ${sub}_wmfod-norm.mif ${sub}_gmfod.mif ${sub}_gmfod-norm.mif ${sub}_csf.mif ${sub}_csf-norm.mif -mask ${sub}_dwi_upsampled-mask.mif
				done

				for tsub in ${templatesubs[@]}
				do
					cp ${indir}${tsub}/${tsub}_wmfod-norm.mif ${templatedir}fod_input/${tsub}_fd.mif
					cp ${indir}${tsub}/${tsub}_dwi_upsampled-mask.mif ${templatedir}mask_input/${tsub}_pre-mask.mif
				done

				population_template ${templatedir}fod_input/ -mask ${templatedir}mask_input/ ${templatedir}wmfod-template.mif -voxel_size 1.25

				for subpath in ${indir}sub*
				do
					subname=${subpath##*/input/}
					sub=${subpath}/${subname}
					mrregister ${sub}_wmfod-norm.mif -mask1 ${sub}_dwi_upsampled-mask.mif ${templatedir}wmfod-template.mif -nl_warp ${sub}_sub2template-warp.mif ${sub}_template2sub-warp.mif
					mrtransform ${sub}_dwi_upsampled-mask.mif -warp ${sub}_sub2template-warp.mif -interp nearest -datatype bit ${sub}_dwi-mask_template-space.mif
					mrtransform ${sub}_dwi_upsampled.mif -warp ${sub}_sub2template-warp.mif -interp nearest ${sub}_dwi_template-space.mif -reorient_fod yes
				done

			elif [[ $fbaselect == 3 ]]
			# Fixel and tensor estimation
			then
				mrmath ${indir}*/*dwi-mask_template-space.mif min ${templatedir}template_mask.mif -datatype bit
				fod2fixel -mask ${templatedir}template_mask.mif -fmls_peak_value 0.06 ${templatedir}wmfod-template.mif ${templatedir}fixel_mask

				for subpath in ${indir}sub*
				do
					subname=${subpath##*/input/}
					sub=${subpath}/${subname}
					mrtransform ${sub}_wmfod-norm.mif -warp ${sub}_sub2template-warp.mif -reorient_fod no ${sub}_fod_template-space.mif
					fod2fixel -mask ${templatedir}template_mask.mif ${sub}_fod_template-space.mif ${sub}_fixel_template-space -afd fd.mif
					fixelreorient ${sub}_fixel_template-space ${sub}_sub2template-warp.mif ${sub}_fixel_template-space_reorient
					fixelcorrespondence ${sub}_fixel_template-space_reorient/fd.mif ${templatedir}fixel_mask ${templatedir}fd ${subname}_fd.mif
					warp2metric ${sub}_sub2template-warp.mif -fc ${templatedir}fixel_mask ${templatedir}fc ${subname}_fc.mif
				done

				cp ${templatedir}fc/index.mif ${templatedir}fc/directions.mif ${templatedir}logfc/
				cp ${templatedir}fc/index.mif ${templatedir}fc/directions.mif ${templatedir}fdc/
				
				for subpath in ${indir}sub*
				do
					subname=${subpath##*/input/}
					mrcalc ${templatedir}fc/${subname}_fc.mif -log ${templatedir}logfc/${subname}_logfc.mif
					mrcalc ${templatedir}fd/${subname}_fd.mif ${templatedir}fc/${subname}_fc.mif -mult ${templatedir}fdc/${subname}_fdc.mif
				done
				
				mkdir -p ${templatedir}ad/ ${templatedir}fa/ ${templatedir}md/ ${templatedir}rd/ ${templatedir}ak/ ${templatedir}mk/ ${templatedir}rk/
				for subpath in ${indir}sub*
				do
					subname=${subpath##*/input/}
					sub=${subpath}/${subname}
					dwi2tensor -mask ${sub}_dwi-mask_template-space.mif ${sub}_dwi_template-space.mif ${sub}_tensor.mif -dkt ${sub}_kurtosis.mif
					rm ${sub}_tensor.mif
					dwiextract ${sub}_dwi_template-space.mif ${sub}_dti_template-space.mif -shells 0,1000 
					dwi2tensor -mask ${sub}_dwi-mask_template-space.mif ${sub}_dti_template-space.mif ${sub}_tensor.mif
					rm ${sub}_dti_template-space.mif
					~/mrtrix3dev/bin/tensor2metric ${sub}_tensor.mif -ad ${templatedir}ad/${subname}_ad.mif -fa ${templatedir}fa/${subname}_fa.mif -adc ${templatedir}md/${subname}_md.mif -rd ${templatedir}rd/${subname}_rd.mif -dkt ${sub}_kurtosis.mif -ak ${templatedir}ak/${subname}_ak.mif -mk ${templatedir}mk/${subname}_mk.mif -rk ${templatedir}rk/${subname}_rk.mif
				done

			elif [[ $fbaselect == 4 ]]
			# Whole brain connectivity
			then
				tckgen -angle 22.5 -maxlen 250 -minlen 10 -power 1.0 ${templatedir}wmfod-template.mif -seed_image ${templatedir}template_mask.mif -mask ${templatedir}template_mask.mif -select 20000000 -cutoff 0.06 ${templatedir}tracks/tracks_020-mill_wholebrain.tck

				tcksift ${templatedir}tracks/tracks_020-mill_wholebrain.tck ${templatedir}wmfod-template.mif ${templatedir}tracks/tracks_001-mill_wholebrain_sift.tck -term_number 1000000

				fixelconnectivity ${templatedir}fixel_mask/ ${templatedir}tracks/tracks_001-mill_wholebrain_sift.tck ${templatedir}matrix/

				for i in fd fdc logfc
				do
					fixelfilter ${templatedir}${i} smooth ${templatedir}${i}_smooth -matrix ${templatedir}matrix/
				done

			elif [[ $fbaselect == 5 ]]
			# FBA is skipped
			then
				echo Fixel-based analysis skipped
				break

			else
				echo Invalid selection.
			fi
		done

	elif [[ $diffselect == 3 ]]
	# TractSeg Processing
	then
		while true	
		do
			source ~/tractseg/bin/activate
			echo Choose TractSeg action:
			echo
			echo 1. Run TractSeg
			echo 2. Skip
			echo
			read "tsselect?Selection (1/4): "
			if [[ $tsselect == 1 ]]
			# Run TractSeg on the population template
			then
				echo $derivdir
				mkdir -p $tractseg_wmdir
				sh2peaks $template_wmfod ${tractseg_wmdir}wmfod-peaks.mif
				mrconvert ${tractseg_wmdir}wmfod-peaks.mif ${tractseg_wmdir}wmfod-peaks.nii.gz

				for i in tract_segmentation endings_segmentation TOM
				do
					tractseg -i ${tractseg_wmdir}wmfod-peaks.nii.gz --output_type ${i}
				done
				tracking -i ${tractseg_wmdir}wmfod-peaks.nii.gz

			elif [[ $tsselect == 2 ]]
			# TractSeg is skipped
			then
				echo TractSeg segmentation skipped
				break

			else
				echo Invalid selection.
			fi
			deactivate
		done
	
	elif [[ $diffselect == 4 ]]
	# Statistics
	then
		while true
		do
			echo Choose FBA action:
			echo
			echo 1. Tract ROIs and profiles
			echo 2. Fixel modeling
			echo 3. Scalar modeling
			echo 4. Skip FBA
			echo
			read "statselect?Selection (1/5): "
			
			fixel2voxel ${templatedir}fixel_mask/directions.mif absmax ${templatedir}fixel_mask/mask-fixel.mif
			mrcalc ${templatedir}fixel_mask/mask-fixel.mif 0 -gt ${templatedir}fixel_mask/mask.mif
			rm ${templatedir}fixel_mask/mask-fixel.mif

			if [[ $statselect == 1 ]]
			# Tract ROIs and profiles
			then
				rm ${bundledir}tracts.csv
				for subpath in ${indir}*
				do
					subname=${subpath##*/input/}
					for i in ad ak fa fd fdc logfc md mk rd rk
					do
						echo ${subname} > ${templatedir}${i}/${subname}.csv
					done
				done
				for tract in ${tractseg_wmdir}tractseg_output/TOM_trackings/*.tck
				do
					tractdir=${tract%%.tck}
					tractname=${tractdir##*TOM_trackings/}
					echo $tractname >> ${bundledir}tracts.csv
					tck2fixel $tract ${templatedir}fd/ $bundledir ${tractname}_fixel.mif
					mrthreshold ${bundledir}${tractname}_fixel.mif -abs 1 ${bundledir}${tractname}_fixel.mif -force
					fixel2voxel ${bundledir}${tractname}_fixel.mif none ${bundledir}${tractname}_voxel.mif
					for subpath in ${indir}*
					do
						subname=${subpath##*/input/}
						for i in fd fdc logfc
							do
							mrstats -output mean ${templatedir}${i}/${subname}*.mif -mask ${bundledir}${tractname}_fixel.mif >> ${templatedir}${i}/${subname}.csv
						done
						for i in ad ak fa md mk rd rk
							do
							mrstats -output mean ${templatedir}${i}/${subname}*.mif -mask ${bundledir}${tractname}_voxel.mif >> ${templatedir}${i}/${subname}.csv
						done
					done
				done
				for i in ad ak fa fd fdc logfc md mk rd rk
				do
					paste -sd "," ${templatedir}${i}/*.csv > ${statsdir}${i}_mean.csv
					rm ${templatedir}${i}/*.csv
				done
								
			elif [[ $statselect == 2 ]]
			# Fixel modeling
			then
				for i in fd fdc logfc
				do
					for j in all ncc hcc
					do
						mkdir -p ${templatedir}stats/${j}/${i}/
						if [[ $j == all ]]
						then
							fixelcfestats ${templatedir}${i}_smooth/ ${groupdir}files_${i}.${j}.txt ${groupdir}design.${j}.txt ${groupdir}contrast.${j}.txt ${templatedir}matrix/ ${templatedir}stats/${j}/${i}/ -mask ${templatedir}fixel_mask/directions.mif -ftest ${groupdir}ftest.${j}.txt
							for k in F1 t1 t2 t3 t4 t5 t6
							do
								for l in 80 95
								do
									mrthreshold  -abs 0.${l} ${templatedir}stats/${j}/${i}/fwe_1mpvalue_${k}.mif ${templatedir}stats/${j}/${i}/sig0${l}-${k}.mif
									fixel2voxel ${templatedir}stats/${j}/${i}/sig0${l}-${k}.mif max ${templatedir}stats/${j}/${i}/sig0${l}-${k}_mask.mif
									tckgen -angle 22.5 -maxlen 25 -minlen 2 -power 1.0 ${templatedir}wmfod-template.mif -seed_image ${templatedir}stats/${j}/${i}/sig0${l}-${k}_mask.mif -mask ${templatedir}template_mask.mif -select 100000 -cutoff 0.06 ${templatedir}tracks/${j}_${i}_sig0${l}-${k}.tck
								done
								fixel2tsf ${templatedir}stats/${j}/${i}/fwe_1mpvalue_${k}.mif ${templatedir}tracks/${j}_${i}_sig080-${k}.tck ${templatedir}stats/${j}/${i}/tracks_fwe_1mpvalue_${k}.tsf
							done
						elif [[ $j == ncc || $j = hcc ]]
						then
							fixelcfestats ${templatedir}${i}_smooth/ ${groupdir}files_${i}.${j}.txt ${groupdir}design.${j}.txt ${groupdir}contrast.${j}.txt ${templatedir}matrix/ ${templatedir}stats/${j}/${i}/ -mask ${templatedir}fixel_mask/directions.mif
							for k in t1 t2
							do
								for l in 80 95
								do
									mrthreshold  -abs 0.${l} ${templatedir}stats/${j}/${i}/fwe_1mpvalue_${k}.mif ${templatedir}stats/${j}/${i}/sig0${l}-${k}.mif
									fixel2voxel ${templatedir}stats/${j}/${i}/sig0${l}-${k}.mif max ${templatedir}stats/${j}/${i}/sig0${l}-${k}_mask.mif
									tckgen -angle 22.5 -maxlen 25 -minlen 2 -power 1.0 ${templatedir}wmfod-template.mif -seed_image ${templatedir}stats/${j}/${i}/sig0${l}-${k}_mask.mif -mask ${templatedir}template_mask.mif -select 100000 -cutoff 0.06 ${templatedir}tracks/${j}_${i}_sig0${l}-${k}.tck
								done
								fixel2tsf ${templatedir}stats/${j}/${i}/fwe_1mpvalue_${k}.mif ${templatedir}tracks/${j}_${i}_sig080-${k}.tck ${templatedir}stats/${j}/${i}/tracks_fwe_1mpvalue_${k}.tsf
							done
						else
							echo Design not found.
						fi
					done
				done
				
			elif [[ $statselect == 3 ]]
			# Scalar modeling
			then
				for i in ad fa md rd ak mk rk
				do
					for j in ncc hcc all
					do
						mkdir -p ${templatedir}stats/${j}/${i}/
						if [[ $j == all ]]
						then
							#mrclusterstats ${groupdir}files_${i}.${j}.txt ${groupdir}design.${j}.txt ${groupdir}contrast.${j}.txt ${templatedir}fixel_mask/mask.mif ${templatedir}stats/${j}/${i}/ -ftest ${groupdir}ftest.${j}.txt
							mrclusterstats ${groupdir}files_${i}.${j}.txt ${groupdir}design.${j}.txt ${groupdir}contrast.${j}.txt ${templatedir}fixel_mask/mask.mif ${templatedir}stats/${j}/${i}/ -ftest ${groupdir}ftest.${j}.txt -nthreads 4
							for k in F1 t1 t2 t3 t4 t5 t6
							do
								voxel2fixel ${templatedir}stats/${j}/${i}/fwe_1mpvalue_${k}.mif ${templatedir}fd/ ${templatedir}stats/${j}/${i} fwe_1mpvalue_${k}-fixel.mif
								for l in 80 95
								do
									mrthreshold -abs 0.${l} ${templatedir}stats/${j}/${i}/fwe_1mpvalue_${k}.mif ${templatedir}stats/${j}/${i}/sig0${l}-${k}.mif
									tckgen -angle 22.5 -maxlen 25 -minlen 2 -power 1.0 ${templatedir}wmfod-template.mif -seed_image ${templatedir}stats/${j}/${i}/sig0${l}-${k}.mif -mask ${templatedir}template_mask.mif -select 100000 -cutoff 0.06 ${templatedir}tracks/${j}_${i}_sig0${l}-${k}.tck
								done
								fixel2tsf ${templatedir}stats/${j}/${i}/fwe_1mpvalue_${k}-fixel.mif ${templatedir}tracks/${j}_${i}_sig080-${k}.tck ${templatedir}stats/${j}/${i}/tracks_fwe_1mpvalue_${k}.tsf
							done
						elif [[ $j == ncc || $j = hcc ]]
						then
							#mrclusterstats ${groupdir}files_${i}.${j}.txt ${groupdir}design.${j}.txt ${groupdir}contrast.${j}.txt ${templatedir}fixel_mask/mask.mif ${templatedir}stats/${j}/${i}/
							mrclusterstats ${groupdir}files_${i}.${j}.txt ${groupdir}design.${j}.txt ${groupdir}contrast.${j}.txt ${templatedir}fixel_mask/mask.mif ${templatedir}stats/${j}/${i}/ -nthreads 4
							for k in t1 t2
							do
								voxel2fixel ${templatedir}stats/${j}/${i}/fwe_1mpvalue_${k}.mif ${templatedir}fd/ ${templatedir}stats/${j}/${i} fwe_1mpvalue_${k}-fixel.mif
								for l in 80 95
								do
									mrthreshold -abs 0.${l} ${templatedir}stats/${j}/${i}/fwe_1mpvalue_${k}.mif ${templatedir}stats/${j}/${i}/sig0${l}-${k}.mif
									tckgen -angle 22.5 -maxlen 25 -minlen 2 -power 1.0 ${templatedir}wmfod-template.mif -seed_image ${templatedir}stats/${j}/${i}/sig0${l}-${k}.mif -mask ${templatedir}template_mask.mif -select 100000 -cutoff 0.06 ${templatedir}tracks/${j}_${i}_sig0${l}-${k}.tck
								done
								fixel2tsf ${templatedir}stats/${j}/${i}/fwe_1mpvalue_${k}-fixel.mif ${templatedir}tracks/${j}_${i}_sig080-${k}.tck ${templatedir}stats/${j}/${i}/tracks_fwe_1mpvalue_${k}.tsf
							done
						else
							echo Design not found.
						fi
					done
				done
				
		elif [[ $statselect == 4 ]]
				# Stats skipped
				then
					echo Stasistics skipped
					break

				else
					echo Invalid selection.
				fi
			done

	elif [[ $diffselect == 5 ]]
	# Images
	then
		# a glass brain and an empty image are created, for visualisation
		mrthreshold -abs 2 ${templatedir}template_mask.mif ${templatedir}empty.mif
		mrconvert ${templatedir}wmfod-template.mif -coord 3 0 -axes 0,1,2 ${templatedir}empty_in.mif
		mrthreshold -abs 0.0000001 ${templatedir}empty_in.mif ${templatedir}empty_mask.mif
		mrfilter ${templatedir}empty_mask.mif smooth ${templatedir}empty_mask.mif -stdev 1.0 -force
		mrthreshold -abs 0.0000001 ${templatedir}empty_mask.mif ${templatedir}empty_mask.mif -force
		mrgrid ${templatedir}empty_mask.mif regrid -scale 3 ${templatedir}empty_mask-upsampled.mif
		mrthreshold -abs 0.8 ${templatedir}empty_mask-upsampled.mif ${templatedir}empty_mask-upsampled-2.mif
		maskfilter ${templatedir}empty_mask-upsampled-2.mif erode -npass 16 ${templatedir}empty_mask-upsampled-3.mif
		maskfilter ${templatedir}empty_mask-upsampled-2.mif erode -npass 18 ${templatedir}empty_mask-upsampled-4.mif
		mrcalc ${templatedir}empty_mask-upsampled-3.mif ${templatedir}empty_mask-upsampled-4.mif -subtract ${templatedir}empty_mask-glass.mif
		mrfilter ${templatedir}empty_mask-glass.mif smooth ${templatedir}template_mask-glass.mif -stdev 1.0 -force
		rm ${templatedir}empty*

		mkdir -p ${fbadir}images

		for i in ad ak fa fd fdc logfc md mk rd rk
		do
			for j in all ncc hcc
			do
				for k in F1 t1 t2 t3 t4 t5 t6
				do
					for l in 80 95
					do
						mrview ${templatedir}empty.mif -mode 3 -noannotation -size 1000,1000 -capture.folder ${fbadir}images/ \
							-overlay.load ${templatedir}template_mask-glass.mif -overlay.colourmap 0 -overlay.opacity 0.02 \
							-tractography.load ${templatedir}tracks/${j}_${i}_sig0${l}-${k}.tck -tractography.thickness -0.3 -tractography.lighting 1 \
							-plane 0 -capture.prefix ${j}_${i}_net0${l}-${k}_sag -capture.grab \
							-plane 1 -capture.prefix ${j}_${i}_net0${l}-${k}_cor -capture.grab \
							-plane 2 -capture.prefix ${j}_${i}_net0${l}-${k}_axi -capture.grab \
							-exit
						mrview ${templatedir}empty.mif -mode 3 -noannotation -size 1000,1000 -capture.folder ${fbadir}images/ \
							-overlay.load ${templatedir}template_mask-glass.mif -overlay.colourmap 0 -overlay.opacity 0.02 \
							-tractography.load ${templatedir}tracks/${j}_${i}_sig080-${k}.tck -tractography.thickness -0.3 -tractography.lighting 1 \
							-tractography.opacity 0.5 \
							-tractography.tsf_load ${templatedir}stats/${j}/${i}/tracks_fwe_1mpvalue_${k}.tsf -tractography.tsf_thresh 0.${l},1 \
							-tractography.tsf_colourmap 4 -tractography.tsf_range 0.${l},1 \
							-plane 0 -capture.prefix ${j}_${i}_sig0${l}-${k}_sag -capture.grab \
							-plane 1 -capture.prefix ${j}_${i}_sig0${l}-${k}_cor -capture.grab \
							-plane 2 -capture.prefix ${j}_${i}_sig0${l}-${k}_axi -capture.grab \
							-exit
					done
				done
			done
		done
	
	elif [[ $diffselect == 6 ]]
	# Diffusion analysis is skipped
	then
		echo Diffusion analysis skipped.
		break

	else
		echo Invalid selection.
	fi
done