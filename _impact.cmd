setMode -bs
setMode -bs
setMode -bs
setMode -bs
setCable -port auto
Identify 
identifyMPM 
attachflash -position 1 -spi "M25P16"
assignfiletoattachedflash -position 1 -file "Y:/work/omega/dragon/current/dragon_firmware/2012-10-06_20-54-56.128492.mcs"
Program -p 1 -dataWidth 1 -spionly -e -v -loadfpga 
attachflash -position 1 -spi "M25P80"
assignfiletoattachedflash -position 1 -file "Y:/work/omega/dragon/current/dragon_firmware/2012-10-06_20-54-56.128492.mcs"
Program -p 1 -dataWidth 1 -spionly -e -v -loadfpga 
Program -p 1 -dataWidth 1 -spionly -e -v -loadfpga 
Program -p 1 -dataWidth 1 -spionly -e -v -loadfpga 
Checksum -p 1 -spionly 
Erase -p 1 -spionly 
BlankCheck -p 1 -spionly 
Program -p 1 -dataWidth 1 -spionly -e -v -loadfpga 
ReadbackToFile -p 1 -file "//psf/Home/work/omega/dragon/current/dragon_firmware/xxxxx.mcs" -spionly 
ReadStatusRegister -p 1 
ReadUsercode -p 1 
ReadIdcode -p 1 
Program -p 1 -dataWidth 1 -spionly -v -loadfpga 
Erase -p 1 -spionly 
Program -p 1 -dataWidth 1 -spionly -v -loadfpga 
setCable -port usb21 -baud 1500000
Program -p 1 -dataWidth 1 -spionly -v -loadfpga 
setCable -port usb21 -baud 750000
Program -p 1 -dataWidth 1 -spionly -v -loadfpga 
Erase -p 1 -spionly 
Program -p 1 -dataWidth 1 -spionly -v -loadfpga 
Program -p 1 -dataWidth 1 -spionly -e -v -loadfpga 
setCable -port usb21 -baud 750000
setCable -port usb21 -baud 750000
setCable -port auto
Program -p 1 -dataWidth 1 -spionly -e -v -loadfpga 
assignFile -p 1 -file "Y:/work/omega/dragon/current/dragon_firmware/2012-10-06_20-54-56.128492.bit"
attachflash -position 1 -spi "M25P80"
assignfiletoattachedflash -position 1 -file "Y:/work/omega/dragon/current/dragon_firmware/2012-10-06_20-54-56.128492.mcs"
Program -p 1 -dataWidth 1 
Program -p 1 -dataWidth 1 -spionly -e -v -loadfpga 
attachflash -position 1 -spi "M25P80"
assignfiletoattachedflash -position 1 -file "Y:/work/omega/dragon/current/dragon_firmware/2012-10-06_20-54-56.128492.mcs"
setMode -bs
deleteDevice -position 1
setMode -bs
setMode -ss
setMode -sm
setMode -hw140
setMode -spi
setMode -acecf
setMode -acempm
setMode -pff
loadProjectFile -file "Y:/work/omega/dragon/current/dragon_firmware/spiflash.ipf"
setMode -bs
setMode -ss
setMode -sm
setMode -hw140
setMode -spi
setMode -acecf
setMode -acempm
setMode -pff
setMode -pff
setMode -pff
setMode -pff
setMode -pff
setMode -pff
setCurrentDesign -version 0
setMode -pff
setCurrentDeviceChain -index 0
setSubmode -pffspi
setMode -pff
setMode -pff
addPromDevice -p 2 -size 1024 -name 1M
deletePromDevice -position 1
setMode -pff
setSubmode -pffspi
generate
setCurrentDesign -version 0
setMode -pff
setMode -bs
setMode -ss
setMode -sm
setMode -hw140
setMode -spi
setMode -acecf
setMode -acempm
setMode -pff
setMode -pff
saveProjectFile -file "Y:/work/omega/dragon/current/dragon_firmware/spiflash.ipf"
setMode -bs
setMode -ss
setMode -sm
setMode -hw140
setMode -spi
setMode -acecf
setMode -acempm
setMode -pff
deletePromDevice -position 1
setCurrentDesign -version 0
deleteDevice -position 1
deleteDesign -version 0
setCurrentDesign -version -1
loadProjectFile -file "Y:/work/omega/dragon/current/dragon_firmware/spiflash.ipf"
setMode -bs
setMode -ss
setMode -sm
setMode -hw140
setMode -spi
setMode -acecf
setMode -acempm
setMode -pff
setMode -pff
setMode -pff
setMode -pff
setMode -pff
setMode -pff
setCurrentDesign -version 0
setMode -pff
setCurrentDeviceChain -index 0
setSubmode -pffspi
setMode -pff
setMode -pff
setMode -pff
setMode -bs
setMode -ss
setMode -sm
setMode -hw140
setMode -spi
setMode -acecf
setMode -acempm
setMode -pff
setMode -pff
saveProjectFile -file "Y:/work/omega/dragon/current/dragon_firmware/spiflash.ipf"
setMode -bs
setMode -ss
setMode -sm
setMode -hw140
setMode -spi
setMode -acecf
setMode -acempm
setMode -pff
deletePromDevice -position 1
setCurrentDesign -version 0
deleteDevice -position 1
deleteDesign -version 0
setCurrentDesign -version -1
setMode -bs
setMode -bs
setMode -bs
setCable -port auto
Identify 
identifyMPM 
attachflash -position 1 -spi "M25P80"
assignfiletoattachedflash -position 1 -file "Y:/work/omega/dragon/current/dragon_firmware/dragon_spi.mcs"
Program -p 1 -dataWidth 1 -spionly -e -v -loadfpga 
Program -p 1 -dataWidth 1 -spionly -e -v -loadfpga 
Erase -p 1 -spionly 
Erase -p 1 -spionly 
Erase -p 1 -spionly 
Program -p 1 -dataWidth 1 -spionly -e -v -loadfpga 
Program -p 1 -dataWidth 1 -spionly -e -v -loadfpga 
Erase -p 1 -spionly 
setMode -bs
deleteDevice -position 1
setMode -bs
setMode -ss
setMode -sm
setMode -hw140
setMode -spi
setMode -acecf
setMode -acempm
setMode -pff
