# ����Ĭ������ļ��ı��루�����Ҫ�Ļ���
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
$data = @{"project"=@()} 
# ������ȫ���Ե���ǰĿ¼
secedit /export /cfg config.cfg /quiet

#�˻����
$userAccounts = Get-WmiObject -Class Win32_UserAccount  
$projectdata = @{"msg"="��ǰ�����˻�Ϊ��$($userAccounts.Name -join ', ')";}  
$data['project']+=$projectdata			

# ��ȡ��ȫ���������ļ�
$config = Get-Content -path config.cfg
# echo $config

# ���������ļ�������������  
foreach ($line in $config) {  
    $config_line = $line -split "="  
    $key = $config_line[0].Trim()  
    $value = $config_line[1].Trim()  
  
    # ���guest�˻�ͣ�ò���  
    if ($key -eq "EnableGuestAccount") {  
        $msg = if ($value -eq "1") { "guest�˻�ͣ�ò��Է��ϱ�׼" } else { "guest�˻�ͣ�ò��Բ����ϱ�׼" }  
        $data.project += @{"msg" = $msg}  
    }  
  
    # ���guest�˻�����������  
    if ($key -eq "NewGuestName") {  
        $msg = if ($value -eq "Guest") { "guest�˻����������Բ����ϱ�׼" } else { "guest�˻����������Է��ϱ�׼" }  
        $data.project += @{"msg" = $msg}  
    }  
  
    # ������븴���Բ���  
    if ($key -eq "PasswordComplexity") {  
        $msg = if ($value -eq "1") { "���븴���Բ��Է��ϱ�׼" } else { "���븴���Բ��Բ����ϱ�׼" }  
        $data.project += @{"msg" = $msg}  
    }  
    
     #������볤����Сֵ����
     if ($key -eq "MinimumPasswordLength") {
        $msg = if ($value -eq "8") { "������Сֵ���Է��ϱ�׼"} else { "������Сֵ���Բ����ϱ�׼"}
        $data.project += @{"msg" = $msg}  
     }

     #��������ʹ�����޲���
     if ($key -eq "MaximumPasswordAge") {
        $msg = if ($value -eq "90") { "�����ʹ�����޲��Է��ϱ�׼"} else { "�����ʹ�����޲��Բ����ϱ�׼"}
        $data.project += @{"msg" = $msg}  
     }

     #����˻�������ֵ����
     if ($key -eq "MinimumPasswordLength") {
        $msg = if ($value -eq "8") { "�˻�������ֵ���Է��ϱ�׼"} else { "�˻�������ֵ���Բ����ϱ�׼"}
        $data.project += @{"msg" = $msg}  
     }
    
}  


#ϵͳ��־�鿴����С����
$Key = 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Eventlog\System'
$name = "MaxSize"
$config = (Get-ItemProperty -Path "Registry::$Key" -ErrorAction Stop).$name
if($config -ge "8192")
        {
            $data.code = "1"
            $projectdata = @{"msg"="ϵͳ��־�鿴����С���ò��Է��ϱ�׼";}
            $data['project']+=$projectdata
        }
        else
        {
            $data.code = "0"
            $projectdata = @{"msg"="ϵͳ��־�鿴����С���ò��Բ����ϱ�׼";}
            $data['project']+=$projectdata
        }
# �������  
$date = Get-Date  
$filePath = "windowsResult.txt"  
  
# ����ļ��Ƿ����  
if (Test-Path $filePath) {  
    # �ļ����ڣ�����ѡ�񸲸ǻ�ɾ��������ѡ�񸲸ǣ�  
    # ע�⣺д�����Ĭ�ϻḲ���ļ����������ﲻ��Ҫ��ʽɾ��  
    Write-Host "�ļ� $filePath �Ѵ��ڣ������������ݡ�"  
} else {  
    Write-Host "�ļ� $filePath �����ڣ����������ļ���"  
}  
  
# д��򸲸��ļ�  
# ע�⣺����ʹ�� Out-File ������ -Encoding utf8 ��ȷ��������ȷ  
# �������� Out-File Ĭ����Ϊ���Ǹ��ǣ�����ļ��Ѵ��ڣ������Բ���Ҫ�����߼�  
$date | Out-File -FilePath $filePath -Encoding utf8 -Append:$false  
  
# ������д�����ݵ��ļ�  
foreach ($item in $data.project) {  
    Write-Host "{'msg':$($item.msg)}"  
    # ʹ�� -Append ������׷�ӵ��ļ�  
    $item.msg | Out-File -FilePath $filePath -Encoding utf8 -Append  
}  


