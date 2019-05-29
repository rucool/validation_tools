# Batch extraction of data for NREL validation
# Written by Sage 1/29/18
# Run as: nohup ./batch_nrel.sh > out_nrel.txt &

./wrf2nc.py 20150601 -d30 -c wrf_ndbc_points.csv -p nrel 
./wrf2nc.py 20150701 -d31 -c wrf_ndbc_points.csv -p nrel 
./wrf2nc.py 20150801 -d31 -c wrf_ndbc_points.csv -p nrel 
./wrf2nc.py 20150901 -d30 -c wrf_ndbc_points.csv -p nrel 
./wrf2nc.py 20151001 -d31 -c wrf_ndbc_points.csv -p nrel 
./wrf2nc.py 20151101 -d30 -c wrf_ndbc_points.csv -p nrel 
./wrf2nc.py 20151201 -d31 -c wrf_ndbc_points.csv -p nrel 

./wrf2nc.py 20160101 -d31 -c wrf_ndbc_points.csv -p nrel 
./wrf2nc.py 20160201 -d29 -c wrf_ndbc_points.csv -p nrel 
./wrf2nc.py 20160301 -d31 -c wrf_ndbc_points.csv -p nrel 
./wrf2nc.py 20160401 -d30 -c wrf_ndbc_points.csv -p nrel 
./wrf2nc.py 20160501 -d31 -c wrf_ndbc_points.csv -p nrel 
