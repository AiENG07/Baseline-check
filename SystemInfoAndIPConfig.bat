@echo off  
echo."====================================================================="
echo."|                                                                   |"
echo."|                 �����������[ �����[���������������[�������[   �����[ �������������[              |"
echo."|                �����X�T�T�����[�����U�����X�T�T�T�T�a���������[  �����U�����X�T�T�T�T�a              |"
echo."|                ���������������U�����U�����������[  �����X�����[ �����U�����U  �������[             |"
echo."|                �����X�T�T�����U�����U�����X�T�T�a  �����U�^�����[�����U�����U   �����U             |"
echo."|                �����U  �����U�����U���������������[�����U �^���������U�^�������������X�a             |"
echo."|                �^�T�a  �^�T�a�^�T�a�^�T�T�T�T�T�T�a�^�T�a  �^�T�T�T�a �^�T�T�T�T�T�a              |"
echo."|                                   SystemInfoAndIPConfig  v1.0     |"
echo."|                                                by AiENG           |"
echo."====================================================================="

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

:: ��ȡWindowsӲ����Ϣ
:: �鿴CPU
echo. CPUӲ����Ϣ: >> "%outputFile%" 
echo. >> "%outputFile%"  
wmic cpu list brief >> "%outputFile%"
:: �鿴�ڴ���������
echo. �ڴ���������: >> "%outputFile%" 
echo. >> "%outputFile%"  
wmic memorychip list brief >> "%outputFile%"
:: �鿴BIOS������Ϣ
echo. BIOS������Ϣ: >> "%outputFile%" 
echo. >> "%outputFile%"  
wmic bios get serialnumber >> "%outputFile%"
:: �鿴�����ڴ�
:: wmic memphysical list brief >> "%outputFile%"
:: �鿴����
:: wmic nic list brief >> "%outputFile%"

:: �鿴Ӳ��Ʒ�Ƽ���С
:: Wmic logicaldisk >> "%outputFile%"
:: �鿴��������
:: wmic volume >> "%outputFile%"

  
echo.  
echo. �ѳɹ���ipconfig��systeminfo��Ϣ�Լ�WindowsӲ����Ϣ���浽 %outputFile%  
pause