@echo off  
echo."____________________________________________________________________"
echo."|                                                                   |"
echo."|                 �����������[ �����[���������������[�������[   �����[ �������������[              |"
echo."|                �����X�T�T�����[�����U�����X�T�T�T�T�a���������[  �����U�����X�T�T�T�T�a              |"
echo."|                ���������������U�����U�����������[  �����X�����[ �����U�����U  �������[             |"
echo."|                �����X�T�T�����U�����U�����X�T�T�a  �����U�^�����[�����U�����U   �����U             |"
echo."|                �����U  �����U�����U���������������[�����U �^���������U�^�������������X�a             |"
echo."|                �^�T�a  �^�T�a�^�T�a�^�T�T�T�T�T�T�a�^�T�a  �^�T�T�T�a �^�T�T�T�T�T�a              |"
echo."|                                   SystemInfoAndIPConfig  v1.0     |"
echo."|___________________________________________________________________|"

:: ��������ļ���·��������  
set outputFile=SystemInfoAndIPConfig.txt  
  
:: �������ļ�����Ŀ¼�Ƿ���ڣ�����������򴴽�  
:: if not exist "%~dp0Temp\" mkdir "%~dp0Temp"  
  
:: ���֮ǰ���ܴ��ڵ�ͬ���ļ�  
if exist "%outputFile%" del "%outputFile%"  
  
:: ��ȡipconfig��Ϣ��׷�ӵ��ļ�  
ipconfig > "%outputFile%"  

:: ׷��һ���������ڷָ�����  
echo. >> "%outputFile%"  
  
:: ��ȡsysteminfo��Ϣ��׷�ӵ��ļ�  
systeminfo >> "%outputFile%"  


  
echo.  
echo. �ѳɹ���ipconfig��systeminfo��Ϣ���浽 %outputFile%  
pause