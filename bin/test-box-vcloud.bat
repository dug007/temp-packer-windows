rem 
rem bin\test-box-vcloud.bat ubuntu1204_vcloud.box ubuntu1204 vcloud vcloud

set box_path=%1
set box_name=%2
set box_provider=%3
set vagrant_provider=%4
set test_src_path=../test/*_spec.rb

set tmp_path=boxtest

if exist %tmp_path% rmdir /s /q %tmp_path%

rem tested only with box-provider=vcloud
vagrant plugin install vagrant-%box_provider%
vagrant plugin install vagrant-serverspec

vagrant box remove %box_name% --provider=%box_provider%
vagrant box add %box_name% %box_path%
if ERRORLEVEL 1 goto :done
mkdir %tmp_path%

@set vcloud_hostname=YOUR-VCLOUD-HOSTNAME
@set vcloud_username=YOUR-VCLOUD-USERNAME
@set vcloud_password=YOUR-VCLOUD-PASSWORD
@set vcloud_org=YOUR-VCLOUD-ORG
@set vcloud_catalog=YOUR-VCLOUD-CATALOG
@set vcloud_vdc=YOUR-VCLOUD-VDC

if "%VAGRANT_HOME%x"=="x" set VAGRANT_HOME=%USERPROFILE%\.vagrant.d

if exist c:\vagrant\resources\test-box-vcloud-credentials.bat call c:\vagrant\resources\test-box-vcloud-credentials.bat

echo Uploading %box_name%.ovf to vCloud %vcloud_hostname% / %vcloud_org% / %vcloud_catalog% / %box_name%
@ovftool --acceptAllEulas --vCloudTemplate --overwrite %VAGRANT_HOME%\boxes\%box_name%\0\%box_provider%\%box_name%.ovf "vcloud://%vcloud_username%:%vcloud_password%@%vcloud_hostname%:443?org=%vcloud_org%&vappTemplate=%box_name%&catalog=%vcloud_catalog%&vdc=%vcloud_vdc%"
if ERRORLEVEL 1 goto :first_upload
goto :test_vagrant_box
:first_upload
@ovftool --acceptAllEulas --vCloudTemplate %VAGRANT_HOME%\boxes\%box_name%\0\%box_provider%\%box_name%.ovf "vcloud://%vcloud_username%:%vcloud_password%@%vcloud_hostname%:443?org=%vcloud_org%&vappTemplate=%box_name%&catalog=%vcloud_catalog%&vdc=%vcloud_vdc%"
if ERRORLEVEL 1 goto :error_vcloud_upload

:test_vagrant_box
@echo Sleeping 240 seconds for vCloud to finish vAppTemplate import
@echo Tests with 120 seconds still cause a 500 internal error while powering on
@echo a vApp in vCloud. So be patient until we have a better upload
@echo solution that waits until the import is really finished.
ping 1.1.1.1 -n 1 -w 240000 > nul

pushd %tmp_path%
call :create_vagrantfile
set VAGRANT_LOG=warn
vagrant up --provider=%vagrant_provider%
if ERRORLEVEL 1 goto :done

echo Sleep 10 seconds
ping 1.1.1.1 -n 1 -w 10000 > nul

vagrant destroy -f
if ERRORLEVEL 1 goto :done
popd

vagrant box remove %box_name% --provider=%box_provider%
if ERRORLEVEL 1 goto :done

goto :done

:error_vcloud_upload
echo Error Uploading box to vCloud with ovftool!
goto :done

:create_vagrantfile

rem to test if rsync works
if not exist testdir\testfile.txt (
  mkdir testdir
  echo Works >testdir\testfile.txt
)

echo Vagrant.configure('2') do ^|config^| >Vagrantfile
echo   config.vm.box = '%box_name%' >>Vagrantfile
echo     config.vm.provider :vcloud do ^|vcloud^| >>Vagrantfile
echo       vcloud.vapp_prefix = "%box_name%" >>Vagrantfile
echo     end >>Vagrantfile
echo   config.vm.provision :serverspec do ^|spec^| >>Vagrantfile
echo     spec.pattern = '../test/*_spec.rb' >>Vagrantfile
echo   end >>Vagrantfile
echo end >>Vagrantfile

exit /b

:done
