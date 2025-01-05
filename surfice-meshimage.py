import gl
gl.resetdefaults()
mesh_dir = f'/meshdir/'			
groups = ['ncc', 'hcc']
tstats = ['tstat1', 'tstat2']
			
for i in groups:
		meshbi = f'{mesh_dir}{i}.lh.obj'
		gl.resetdefaults()
		gl.cameradistance(1.4)
		gl.meshloadbilateral(meshbi)
		gl.shadername('phong_matte')
		gl.shaderambientocclusion(.35)
		gl.orientcubevisible(0)
		gl.colorbarvisible(0)
		gl.overlaycloseall()
		for j in tstats:
			overlay_base = f'{mesh_dir}{i}.lh.nii.gz'
			gl.overlayload(overlay_base)
			gl.overlaycolorname(1, 'viridis')
			gl.overlayopacity(1, 50)
			overlay_accu = f'{mesh_dir}{i}.{j}.Accu.lh.sig.nii.gz'
			gl.overlayload(overlay_accu)
			gl.overlaycolorname(2, 'red-yellow')
			gl.overlayminmax(2, 2, 4)
			overlay_amyg = f'{mesh_dir}{i}.{j}.amyg.lh.sig.nii.gz'
			gl.overlayload(overlay_amyg)
			gl.overlaycolorname(3, 'red-yellow')
			gl.overlayminmax(3, 2, 4)
			overlay_caud = f'{mesh_dir}{i}.{j}.caud.lh.sig.nii.gz'
			gl.overlayload(overlay_caud)
			gl.overlaycolorname(4, 'red-yellow')
			gl.overlayminmax(4, 2, 4)
			overlay_hipp = f'{mesh_dir}{i}.{j}.hipp.lh.sig.nii.gz'
			gl.overlayload(overlay_hipp)
			gl.overlaycolorname(5, 'red-yellow')
			gl.overlayminmax(5, 2, 4)
			overlay_pall = f'{mesh_dir}{i}.{j}.pall.lh.sig.nii.gz'
			gl.overlayload(overlay_pall)
			gl.overlaycolorname(6, 'red-yellow')
			gl.overlayminmax(6, 2, 4)
			overlay_puta = f'{mesh_dir}{i}.{j}.puta.lh.sig.nii.gz'
			gl.overlayload(overlay_puta)
			gl.overlaycolorname(7, 'red-yellow')
			gl.overlayminmax(7, 2, 4)
			overlay_thal = f'{mesh_dir}{i}.{j}.thal.lh.sig.nii.gz'
			gl.overlayload(overlay_thal)
			gl.overlaycolorname(8, 'red-yellow')
			gl.overlayminmax(8, 2, 4)
			overlay_accu = f'{mesh_dir}{i}.{j}.Accu.lh.sig.nii.gz'
			gl.overlayload(overlay_accu)
			gl.overlaycolorname(9, 'blue-green')
			gl.overlayminmax(9, -4, -2)
			overlay_amyg = f'{mesh_dir}{i}.{j}.amyg.lh.sig.nii.gz'
			gl.overlayload(overlay_amyg)
			gl.overlaycolorname(10, 'blue-green')
			gl.overlayminmax(10, -4, -2)
			overlay_caud = f'{mesh_dir}{i}.{j}.caud.lh.sig.nii.gz'
			gl.overlayload(overlay_caud)
			gl.overlaycolorname(11, 'blue-green')
			gl.overlayminmax(11, -4, -2)
			overlay_hipp = f'{mesh_dir}{i}.{j}.hipp.lh.sig.nii.gz'
			gl.overlayload(overlay_hipp)
			gl.overlaycolorname(12, 'blue-green')
			gl.overlayminmax(12, -4, -2)
			overlay_pall = f'{mesh_dir}{i}.{j}.pall.lh.sig.nii.gz'
			gl.overlayload(overlay_pall)
			gl.overlaycolorname(13, 'blue-green')
			gl.overlayminmax(13, -4, -2)
			overlay_puta = f'{mesh_dir}{i}.{j}.puta.lh.sig.nii.gz'
			gl.overlayload(overlay_puta)
			gl.overlaycolorname(14, 'blue-green')
			gl.overlayminmax(14, -4, -2)
			overlay_thal = f'{mesh_dir}{i}.{j}.thal.lh.sig.nii.gz'
			gl.overlayload(overlay_thal)
			gl.overlaycolorname(15, 'blue-green')
			gl.overlayminmax(15, -4, -2)
			gl.shaderadjust('Diffuse', 1)
			gl.hemispherepry(105)
			gl.hemispheredistance(0.8)
			gl.azimuthelevation(180, 0)
			ss1 = f'{i}.{j}_a180_e20.png'
			gl.savebmpxy(ss1, 2000, 3000)
			gl.hemispherepry(-75)
			gl.hemispheredistance(1)
			gl.azimuthelevation(180, 0)
			ss2 = f'{i}.{j}_a0_e-20.png'
			gl.savebmpxy(ss2, 2000, 3000)
			gl.overlaycloseall()

groups = ['all']
tstats = ['fstat1', 'tstat1', 'tstat2', 'tstat3', 'tstat4', 'tstat5', 'tstat6']
			
for i in groups:
		meshbi = f'{mesh_dir}{i}.lh.obj'
		gl.resetdefaults()
		gl.cameradistance(1.4)
		gl.meshloadbilateral(meshbi)
		gl.shadername('phong_matte')
		gl.shaderambientocclusion(.35)
		gl.orientcubevisible(0)
		gl.colorbarvisible(0)
		gl.overlaycloseall()
		for j in tstats:
			overlay_base = f'{mesh_dir}{i}.lh.nii.gz'
			gl.overlayload(overlay_base)
			gl.overlaycolorname(1, 'viridis')
			gl.overlayopacity(1, 50)
			overlay_accu = f'{mesh_dir}{i}.{j}.Accu.lh.sig.nii.gz'
			gl.overlayload(overlay_accu)
			gl.overlaycolorname(2, 'red-yellow')
			gl.overlayminmax(2, 2, 4)
			overlay_amyg = f'{mesh_dir}{i}.{j}.amyg.lh.sig.nii.gz'
			gl.overlayload(overlay_amyg)
			gl.overlaycolorname(3, 'red-yellow')
			gl.overlayminmax(3, 2, 4)
			overlay_caud = f'{mesh_dir}{i}.{j}.caud.lh.sig.nii.gz'
			gl.overlayload(overlay_caud)
			gl.overlaycolorname(4, 'red-yellow')
			gl.overlayminmax(4, 2, 4)
			overlay_hipp = f'{mesh_dir}{i}.{j}.hipp.lh.sig.nii.gz'
			gl.overlayload(overlay_hipp)
			gl.overlaycolorname(5, 'red-yellow')
			gl.overlayminmax(5, 2, 4)
			overlay_pall = f'{mesh_dir}{i}.{j}.pall.lh.sig.nii.gz'
			gl.overlayload(overlay_pall)
			gl.overlaycolorname(6, 'red-yellow')
			gl.overlayminmax(6, 2, 4)
			overlay_puta = f'{mesh_dir}{i}.{j}.puta.lh.sig.nii.gz'
			gl.overlayload(overlay_puta)
			gl.overlaycolorname(7, 'red-yellow')
			gl.overlayminmax(7, 2, 4)
			overlay_thal = f'{mesh_dir}{i}.{j}.thal.lh.sig.nii.gz'
			gl.overlayload(overlay_thal)
			gl.overlaycolorname(8, 'red-yellow')
			gl.overlayminmax(8, 2, 4)
			overlay_accu = f'{mesh_dir}{i}.{j}.Accu.lh.sig.nii.gz'
			gl.overlayload(overlay_accu)
			gl.overlaycolorname(9, 'blue-green')
			gl.overlayminmax(9, -4, -2)
			overlay_amyg = f'{mesh_dir}{i}.{j}.amyg.lh.sig.nii.gz'
			gl.overlayload(overlay_amyg)
			gl.overlaycolorname(10, 'blue-green')
			gl.overlayminmax(10, -4, -2)
			overlay_caud = f'{mesh_dir}{i}.{j}.caud.lh.sig.nii.gz'
			gl.overlayload(overlay_caud)
			gl.overlaycolorname(11, 'blue-green')
			gl.overlayminmax(11, -4, -2)
			overlay_hipp = f'{mesh_dir}{i}.{j}.hipp.lh.sig.nii.gz'
			gl.overlayload(overlay_hipp)
			gl.overlaycolorname(12, 'blue-green')
			gl.overlayminmax(12, -4, -2)
			overlay_pall = f'{mesh_dir}{i}.{j}.pall.lh.sig.nii.gz'
			gl.overlayload(overlay_pall)
			gl.overlaycolorname(13, 'blue-green')
			gl.overlayminmax(13, -4, -2)
			overlay_puta = f'{mesh_dir}{i}.{j}.puta.lh.sig.nii.gz'
			gl.overlayload(overlay_puta)
			gl.overlaycolorname(14, 'blue-green')
			gl.overlayminmax(14, -4, -2)
			overlay_thal = f'{mesh_dir}{i}.{j}.thal.lh.sig.nii.gz'
			gl.overlayload(overlay_thal)
			gl.overlaycolorname(15, 'blue-green')
			gl.overlayminmax(15, -4, -2)
			#gl.overlayminmax(2, 0.80, 1)
			gl.shaderadjust('Diffuse', 1)
			gl.hemispherepry(105)
			gl.hemispheredistance(0.8)
			gl.azimuthelevation(180, 0)
			ss1 = f'{i}.{j}_a180_e20.png'
			gl.savebmpxy(ss1, 2000, 3000)
			gl.hemispherepry(-75)
			gl.hemispheredistance(1)
			gl.azimuthelevation(180, 0)
			ss2 = f'{i}.{j}_a0_e-20.png'
			gl.savebmpxy(ss2, 2000, 3000)
			gl.overlaycloseall()