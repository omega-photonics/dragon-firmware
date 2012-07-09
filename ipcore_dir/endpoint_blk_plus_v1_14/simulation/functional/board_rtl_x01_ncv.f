// PCI-Express Test Bench
//---------------------------------

../board.v
../sys_clk_gen.v
../sys_clk_gen_ds.v

// PCI-Express 1 Lane Endpoint Reference Design
//----------------------------------------------

-f ../xilinx_pci_exp_cor_ep.f


//Xilinx PCI Express Root Complex Model
//--------------------------------------------

../dsport/gtx_tx_sync_rate_v6.v
../dsport/gtx_wrapper_v6.v
../dsport/pcie_gtx_v6.v
../dsport/pcie_bram_v6.v
../dsport/pcie_brams_v6.v
../dsport/pcie_bram_top_v6.v
../dsport/pcie_pipe_v6.v
../dsport/pcie_pipe_misc_v6.v
../dsport/pcie_pipe_lane_v6.v
../dsport/pcie_clocking_v6.v
../dsport/pcie_reset_delay_v6.v
../dsport/pci_exp_usrapp_rx.v
../dsport/pci_exp_usrapp_tx.v
../dsport/pci_exp_usrapp_com.v
../dsport/pci_exp_usrapp_cfg.v
../dsport/pci_exp_usrapp_pl.v
../dsport/pcie_2_0_rport_v6.v
../dsport/xilinx_pcie_2_0_rport_v6.v
