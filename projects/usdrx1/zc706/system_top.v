// ***************************************************************************
// ***************************************************************************
// Copyright 2014 - 2017 (c) Analog Devices, Inc. All rights reserved.
//
// In this HDL repository, there are many different and unique modules, consisting
// of various HDL (Verilog or VHDL) components. The individual modules are
// developed independently, and may be accompanied by separate and unique license
// terms.
//
// The user should read each of these license terms, and understand the
// freedoms and responsabilities that he or she has by using this source/core.
//
// This core is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
// A PARTICULAR PURPOSE.
//
// Redistribution and use of source or resulting binaries, with or without modification
// of this file, are permitted under one of the following two license terms:
//
//   1. The GNU General Public License version 2 as published by the
//      Free Software Foundation, which can be found in the top level directory
//      of this repository (LICENSE_GPL2), and also online at:
//      <https://www.gnu.org/licenses/old-licenses/gpl-2.0.html>
//
// OR
//
//   2. An ADI specific BSD license, which can be found in the top level directory
//      of this repository (LICENSE_ADIBSD), and also on-line at:
//      https://github.com/analogdevicesinc/hdl/blob/master/LICENSE_ADIBSD
//      This will allow to generate bit files and not release the source code,
//      as long as it attaches to an ADI device.
//
// ***************************************************************************
// ***************************************************************************

`timescale 1ns/100ps

module system_top (

  inout       [14:0]      ddr_addr,
  inout       [ 2:0]      ddr_ba,
  inout                   ddr_cas_n,
  inout                   ddr_ck_n,
  inout                   ddr_ck_p,
  inout                   ddr_cke,
  inout                   ddr_cs_n,
  inout       [ 3:0]      ddr_dm,
  inout       [31:0]      ddr_dq,
  inout       [ 3:0]      ddr_dqs_n,
  inout       [ 3:0]      ddr_dqs_p,
  inout                   ddr_odt,
  inout                   ddr_ras_n,
  inout                   ddr_reset_n,
  inout                   ddr_we_n,

  inout                   fixed_io_ddr_vrn,
  inout                   fixed_io_ddr_vrp,
  inout       [53:0]      fixed_io_mio,
  inout                   fixed_io_ps_clk,
  inout                   fixed_io_ps_porb,
  inout                   fixed_io_ps_srstb,

  inout       [14:0]      gpio_bd,

  output                  hdmi_out_clk,
  output                  hdmi_vsync,
  output                  hdmi_hsync,
  output                  hdmi_data_e,
  output      [23:0]      hdmi_data,

  output                  spdif,

  input                   sys_rst,
  input                   sys_clk_p,
  input                   sys_clk_n,

  output      [13:0]      ddr3_addr,
  output      [ 2:0]      ddr3_ba,
  output                  ddr3_cas_n,
  output      [ 0:0]      ddr3_ck_n,
  output      [ 0:0]      ddr3_ck_p,
  output      [ 0:0]      ddr3_cke,
  output      [ 0:0]      ddr3_cs_n,
  output      [ 7:0]      ddr3_dm,
  inout       [63:0]      ddr3_dq,
  inout       [ 7:0]      ddr3_dqs_n,
  inout       [ 7:0]      ddr3_dqs_p,
  output      [ 0:0]      ddr3_odt,
  output                  ddr3_ras_n,
  output                  ddr3_reset_n,
  output                  ddr3_we_n,

  inout                   iic_scl,
  inout                   iic_sda,

  input                   rx_ref_clk_p,
  input                   rx_ref_clk_n,
  output                  rx_sysref_p,
  output                  rx_sysref_n,
  output                  rx_sync_p,
  output                  rx_sync_n,
  input       [ 7:0]      rx_data_p,
  input       [ 7:0]      rx_data_n,

  output                  spi_fout_enb_clk,
  output                  spi_fout_enb_mlo,
  output                  spi_fout_enb_rst,
  output                  spi_fout_enb_sync,
  output                  spi_fout_enb_sysref,
  output                  spi_fout_enb_trig,
  output                  spi_fout_clk,
  output                  spi_fout_sdio,
  output      [ 3:0]      spi_afe_csn,
  output                  spi_afe_clk,
  inout                   spi_afe_sdio,
  output                  spi_clk_csn,
  output                  spi_clk_clk,
  inout                   spi_clk_sdio,

  output                  afe_mlo_p,
  output                  afe_mlo_n,
  output                  afe_rst_p,
  output                  afe_rst_n,
  output                  afe_trig_p,
  output                  afe_trig_n,

  output                  dac_sleep,
  output      [13:0]      dac_data,
  output                  afe_pdn,
  output                  afe_stby,
  output                  clk_resetn,
  output                  clk_syncn,
  input                   clk_status,
  output                  amp_disbn,
  inout                   prc_sck,
  inout                   prc_cnv,
  inout                   prc_sdo_i,
  inout                   prc_sdo_q);

  // internal signals

  wire                    afe_trig;
  wire                    afe_rst;
  wire        [ 4:0]      spi_csn;
  wire                    spi_clk;
  wire                    spi_mosi;
  wire                    spi_miso;
  wire                    rx_ref_clk;
  wire                    rx_sysref;
  wire                    rx_sync;
  wire        [63:0]      gpio_i;
  wire        [63:0]      gpio_o;
  wire        [63:0]      gpio_t;
  wire        [15:0]      ps_intrs;
  wire                    rx_clk;

  // instantiations

  IBUFDS_GTE2 i_ibufds_rx_ref_clk (
    .CEB (1'd0),
    .I (rx_ref_clk_p),
    .IB (rx_ref_clk_n),
    .O (rx_ref_clk),
    .ODIV2 ());

  OBUFDS i_obufds_rx_sysref (
    .I (rx_sysref),
    .O (rx_sysref_p),
    .OB (rx_sysref_n));

  OBUFDS i_obufds_rx_sync (
    .I (rx_sync),
    .O (rx_sync_p),
    .OB (rx_sync_n));

  OBUFDS i_obufds_gpio_afe_trig (
    .I (afe_trig),
    .O (afe_trig_p),
    .OB (afe_trig_n));

  OBUFDS i_obufds_gpio_afe_rst (
    .I (afe_rst),
    .O (afe_rst_p),
    .OB (afe_rst_n));

  OBUFDS i_obufds_afe_mlo (
    .I (1'b0),
    .O (afe_mlo_p),
    .OB (afe_mlo_n));

  // gpio usdrx1

  assign gpio_i[59:45] = gpio_o[59:45];
  assign dac_data = gpio_o[59:45];
  assign dac_sleep = gpio_o[44];

  ad_iobuf #(.DATA_WIDTH(4)) i_iobuf_prc (
    .dio_t (gpio_t[43:40]),
    .dio_i (gpio_o[43:40]),
    .dio_o (gpio_i[43:40]),
    .dio_p ({prc_sdo_q, prc_sdo_i, prc_cnv, prc_sck}));

  assign gpio_i[39] = gpio_o[39];
  assign amp_disbn  = gpio_o[39];

  assign gpio_i[38] = clk_status;

  assign gpio_i[37:32] = gpio_o[37:32];
  assign clk_syncn  = gpio_o[37];
  assign clk_resetn = gpio_o[36];
  assign afe_stby = gpio_o[35];
  assign afe_pdn = gpio_o[34];
  assign afe_trig = gpio_o[33];
  assign afe_rst = gpio_o[32];

  // gpio zc706

  assign gpio_i[31:15] = gpio_o[31:15];

  ad_iobuf #(.DATA_WIDTH(15)) i_iobuf_bd (
    .dio_t (gpio_t[14:0]),
    .dio_i (gpio_o[14:0]),
    .dio_o (gpio_i[14:0]),
    .dio_p (gpio_bd));

  // spi

  assign spi_fout_enb_clk = 1'b0;
  assign spi_fout_enb_mlo = 1'b0;
  assign spi_fout_enb_rst = 1'b0;
  assign spi_fout_enb_sync = 1'b0;
  assign spi_fout_enb_sysref = 1'b0;
  assign spi_fout_enb_trig = 1'b0;
  assign spi_fout_sdio = 1'b0;
  assign spi_fout_clk = 1'b0;

  assign spi_afe_csn = spi_csn[4:1];
  assign spi_clk_csn = spi_csn[0];
  assign spi_afe_clk = spi_clk;
  assign spi_clk_clk = spi_clk;

  usdrx1_spi i_spi (
    .spi_afe_csn (spi_csn[4:1]),
    .spi_clk_csn (spi_csn[0]),
    .spi_clk (spi_clk),
    .spi_mosi (spi_mosi),
    .spi_miso (spi_miso),
    .spi_afe_sdio (spi_afe_sdio),
    .spi_clk_sdio (spi_clk_sdio));

  // sysref
 
  ad_sysref_gen i_sysref (
    .core_clk (rx_clk),
    .sysref_en (gpio_o[60]),
    .sysref_out (rx_sysref));

  // ipi-system

  system_wrapper i_system_wrapper (
    .axi_usdrx1_xcvr_cpll_ref_clk (rx_ref_clk),
    .axi_usdrx1_xcvr_qpll_ref_clk (rx_ref_clk),
    .axi_usdrx1_xcvr_rx_data_n (rx_data_n),
    .axi_usdrx1_xcvr_rx_data_p (rx_data_p),
    .axi_usdrx1_xcvr_tx_data_n (),
    .axi_usdrx1_xcvr_tx_data_p (),
    .ddr3_addr (ddr3_addr),
    .ddr3_ba (ddr3_ba),
    .ddr3_cas_n (ddr3_cas_n),
    .ddr3_ck_n (ddr3_ck_n),
    .ddr3_ck_p (ddr3_ck_p),
    .ddr3_cke (ddr3_cke),
    .ddr3_cs_n (ddr3_cs_n),
    .ddr3_dm (ddr3_dm),
    .ddr3_dq (ddr3_dq),
    .ddr3_dqs_n (ddr3_dqs_n),
    .ddr3_dqs_p (ddr3_dqs_p),
    .ddr3_odt (ddr3_odt),
    .ddr3_ras_n (ddr3_ras_n),
    .ddr3_reset_n (ddr3_reset_n),
    .ddr3_we_n (ddr3_we_n),
    .ddr_addr (ddr_addr),
    .ddr_ba (ddr_ba),
    .ddr_cas_n (ddr_cas_n),
    .ddr_ck_n (ddr_ck_n),
    .ddr_ck_p (ddr_ck_p),
    .ddr_cke (ddr_cke),
    .ddr_cs_n (ddr_cs_n),
    .ddr_dm (ddr_dm),
    .ddr_dq (ddr_dq),
    .ddr_dqs_n (ddr_dqs_n),
    .ddr_dqs_p (ddr_dqs_p),
    .ddr_odt (ddr_odt),
    .ddr_ras_n (ddr_ras_n),
    .ddr_reset_n (ddr_reset_n),
    .ddr_we_n (ddr_we_n),
    .fixed_io_ddr_vrn (fixed_io_ddr_vrn),
    .fixed_io_ddr_vrp (fixed_io_ddr_vrp),
    .fixed_io_mio (fixed_io_mio),
    .fixed_io_ps_clk (fixed_io_ps_clk),
    .fixed_io_ps_porb (fixed_io_ps_porb),
    .fixed_io_ps_srstb (fixed_io_ps_srstb),
    .gpio_i (gpio_i),
    .gpio_o (gpio_o),
    .gpio_t (gpio_t),
    .hdmi_data (hdmi_data),
    .hdmi_data_e (hdmi_data_e),
    .hdmi_hsync (hdmi_hsync),
    .hdmi_out_clk (hdmi_out_clk),
    .hdmi_vsync (hdmi_vsync),
    .iic_main_scl_io (iic_scl),
    .iic_main_sda_io (iic_sda),
    .ps_intr_00 (1'b0),
    .ps_intr_01 (1'b0),
    .ps_intr_02 (1'b0),
    .ps_intr_03 (1'b0),
    .ps_intr_04 (1'b0),
    .ps_intr_05 (1'b0),
    .ps_intr_06 (1'b0),
    .ps_intr_07 (1'b0),
    .ps_intr_08 (1'b0),
    .ps_intr_09 (1'b0),
    .ps_intr_10 (1'b0),
    .ps_intr_11 (1'b0),
    .ps_intr_12 (1'b0),
    .ps_intr_13 (1'b0),
    .rx_core_clk (rx_clk),
    .rx_sync (rx_sync),
    .rx_sysref (rx_sysref),
    .spdif (spdif),
    .spi0_clk_i (1'd0),
    .spi0_clk_o (),
    .spi0_csn_0_o (),
    .spi0_csn_1_o (),
    .spi0_csn_2_o (),
    .spi0_csn_i (1'd0),
    .spi0_sdi_i (1'd0),
    .spi0_sdo_i (1'd0),
    .spi0_sdo_o (),
    .spi1_clk_i (1'd0),
    .spi1_clk_o (),
    .spi1_csn_0_o (),
    .spi1_csn_1_o (),
    .spi1_csn_2_o (),
    .spi1_csn_i (1'd0),
    .spi1_sdi_i (1'd0),
    .spi1_sdo_i (1'd0),
    .spi1_sdo_o (),
    .spi_clk (spi_clk),
    .spi_csn (spi_csn),
    .spi_miso (spi_miso),
    .spi_mosi (spi_mosi),
    .sys_clk_clk_n (sys_clk_n),
    .sys_clk_clk_p (sys_clk_p),
    .sys_rst (sys_rst));

endmodule

// ***************************************************************************
// ***************************************************************************
