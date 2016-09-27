
%clc;clear all;close all;
Chat_PC_A_Tx;                          %
x=data_bin; 
N=length(x);                            %length of data
fc=2500;                              %carrier frequncy
transmitter(x,fc)