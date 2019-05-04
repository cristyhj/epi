`timescale 1ns / 1ps


/*! 
 *  \brief &nbsp; This module is used only in simulation and generates requests prom a  processing unit.
 *	
 *	&nbsp; Simulates the two interfaces of an AXI Ethernet core: status and data interfaces.
 *
 *	\todo 
 */
module pu_requests # (

    parameter 		TCQ   				= 1'b1,		//% Delay used for simulation
    parameter 		AXI_DATA_WIDTH   	= 32,		//% AXI Lite data address width
	parameter		TRANSACTION_FILE	= "",
	parameter		TRANSACTIONS_NR		= 4,
	parameter		TRANSACTION_WIDTH	= 32
	
) (
	
	input   wire            	axis_aresetn,
	input   wire            	axis_clk,
	
	// Ethernet - Axi4 Stream data interface
	output	reg [AXI_DATA_WIDTH-1:0]	m_axis_data_tdata,				//% (Master: AXI Ethernet - data interface) Write data  	
	output	reg [3:0]					m_axis_data_tkeep,				//% (Master: AXI Ethernet - data interface) Keep octets - 1 bit for every 8 bits of valid data
	output	reg							m_axis_data_tlast,				//% (Master: AXI Ethernet - data interface) Indicates the last transfer of data
	input 	wire						m_axis_data_tready,				//% (Master: AXI Ethernet - data interface) Read ready - master can accept the read data and response
	output	reg							m_axis_data_tvalid = 1'b0,		//% (Master: AXI Ethernet - data interface) Read valid issued by master - data is valid
	
	// Ethernet - Axi4 Stream status interface
	output  reg [AXI_DATA_WIDTH-1:0]	m_axis_sts_tdata,				//% (Master: AXI Ethernet - status interface) Write data  	
	output  reg [3:0]					m_axis_sts_tkeep,				//% (Master: AXI Ethernet - status interface) Keep octets - 1 bit for every 8 bits of valid data
	output  reg							m_axis_sts_tlast,				//% (Master: AXI Ethernet - status interface) Indicates the last transfer of data
	input   wire						m_axis_sts_tready,				//% (Master: AXI Ethernet - status interface) Read ready - master can accept the read data and response
	output  reg							m_axis_sts_tvalid = 1'b0		//% (Master: AXI Ethernet - status interface) Read valid issued by master - data is valid

);
  

// Generate transaction
//
localparam 		transaction_nr 		= TRANSACTIONS_NR,
				transaction_width	= TRANSACTION_WIDTH;	// Tne width of a transaction in bits
				
reg	[transaction_width-1:0]   	transactions [transaction_nr-1:0];
reg [transaction_width-1:0]		data_to_send;

// Initialize transactions
initial $readmemh(TRANSACTION_FILE, transactions);
				
reg [7:0]		transaction_index;				// The transaction that need to be sent
reg [15:0]		bit_index;						// The LSB bit from transaction that is now sent
reg	[15:0]		next_bit_index;					// The bit_index register substracted by 32
reg				sending_transaction;			// Indicates that a transaction started 	
reg [4:0]		inter_trans_counter = 5'h00;	// Wait conter used to inject a delay after a transaction was sent

reg				status_sent = 1'b0;				// To simulate a transaction from AXI Ethernet CORE a status transfer must be sent first
reg [2:0]		status_word_cnt = 3'h5;			// Counts the number of the words sent on status interface

////////////////////////////////////////////////////////////////////////////
/*!
 *	\brief &nbsp; This process sends a number of transaction_nr 
 *	SPI transactions to the slave.
 */
////////////////////////////////////////////////////////////////////////////
//
always @ (posedge axis_clk) begin
	if (axis_aresetn == 1'b0 ) begin	
	////////////////////////////////////////////////////////////////////////////
	// reset condition
	//
		transaction_index		<= #TCQ 2'h0;
		bit_index				<= #TCQ transaction_width - 32;
		next_bit_index			<= #TCQ transaction_width - 64;
		
		status_sent				<= #TCQ 1'b0;
		status_word_cnt			<= #TCQ 3'h5;
		
		inter_trans_counter		<= #TCQ 5'h00;
		sending_transaction		<= #TCQ 1'b0;
		m_axis_data_tvalid 		<= #TCQ 1'b0;
		
		m_axis_sts_tvalid 		<= #TCQ 1'b0;
		m_axis_sts_tdata		<= #TCQ 32'h00000000;
	//
	end else begin 	
		
		
		if(transaction_index < transaction_nr) begin
		
			m_axis_data_tkeep	<= #TCQ 4'hF;
			m_axis_sts_tkeep	<= #TCQ 4'hF;
			m_axis_data_tlast	<= #TCQ (m_axis_data_tlast & ~m_axis_data_tvalid) ? 1'b1 : 1'b0;
			// m_axis_data_tlast	<= #TCQ 1'b1;
			
			// Check if the the transaction started and if
			// the status words were sent
			if(sending_transaction & status_sent) begin
				m_axis_data_tvalid 	<= #TCQ 1'b1;
				// m_axis_data_tvalid 	<= #TCQ ~m_axis_data_tvalid;
			end
				
			if(sending_transaction == 1'b1 && m_axis_data_tready && m_axis_data_tvalid) begin
						 
				bit_index 			<= #TCQ bit_index - 32;
				// next_bit_index		<= #TCQ bit_index - 64;
				// m_axis_data_tdata 	<= #TCQ transactions[ transaction_index ] >> next_bit_index;
				
				data_to_send		<= #TCQ data_to_send >> 32;
				m_axis_data_tdata 	<= #TCQ data_to_send >> 32;
								
				if(bit_index == 16'd0) begin
					
					sending_transaction <= #TCQ 1'b0;
					
					m_axis_data_tvalid	<= #TCQ 1'b0;
					m_axis_data_tlast	<= #TCQ 1'b0;
					
					bit_index 			<= #TCQ transaction_width - 32;				
					transaction_index	<= #TCQ transaction_index + 2'b01;				
					//
				end
				
				if(bit_index == 32) begin
					m_axis_data_tlast	<= #TCQ 1'b1;
				end
				//
			end else begin
				// m_axis_data_tdata 	<= #TCQ transactions[ transaction_index ] >> bit_index;	
				// next_bit_index		<= #TCQ bit_index - 32;
				m_axis_data_tdata 		<= #TCQ data_to_send[31:0];
			end
			
			if(sending_transaction == 0) begin
				status_word_cnt			<= #TCQ 3'h5;
				inter_trans_counter		<= #TCQ inter_trans_counter + 5'h01;
				sending_transaction 	<= #TCQ inter_trans_counter == 5'hFF ? 1'b1 : 1'b0;
			end
			
			/////////////////////////////////////////////////////////
			// Logic for sending status words
			
			if(sending_transaction & ~status_sent) begin
				status_word_cnt		<= #TCQ (m_axis_sts_tready & m_axis_sts_tvalid) ? status_word_cnt - 3'h1 : status_word_cnt;
                m_axis_sts_tdata	<= #TCQ {data_to_send[119:112], data_to_send[127:120], 16'd0};
				m_axis_sts_tlast	<= #TCQ status_word_cnt == 3'h1 ? 1'b1 : 1'b0;						
				m_axis_sts_tvalid	<= #TCQ status_word_cnt == 3'h0 ? 1'b0 : 1'b1;		
			end else begin
				m_axis_sts_tlast	<= #TCQ 1'b0;
				m_axis_sts_tvalid	<= #TCQ 1'b0;
			end 			
			
			if(sending_transaction == 0) begin
				status_sent			<= #TCQ 1'h0;
				data_to_send		<= #TCQ transactions[transaction_index];
			end else if(status_word_cnt == 3'h0) begin
				status_sent			<= #TCQ 1'b1;
			end else begin
				status_sent			<= #TCQ status_sent;
			end
			/////////////////////////////////////////////////////////			
		//
		end
	//
  end	// if (reset) end
end	// always end


	


endmodule





























