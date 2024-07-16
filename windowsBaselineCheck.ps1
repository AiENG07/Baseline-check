# ����Ĭ������ļ��ı��루�����Ҫ�Ļ���
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
$data = @{"project"=@()} 
# ������ȫ���Ե���ǰĿ¼
secedit /export /cfg config.cfg /quiet

#�˻����
$userAccounts = Get-WmiObject -Class Win32_UserAccount  
# echo $userAccounts
# $projectdata = @{"msg"="��ǰ�ն˴��ڵ��˻���$($userAccounts.Name -join ', ')";}  
# $data['project']+=$projectdata	
$data.project += @{"msg" = "��ǰ�ն˴��ڵ��˻���$($userAccounts.Name -join ', ')"} 
$data.project += @{"msg" = "   "}

#IP���
# $IPInfo = Get-NetIPAddress
# echo  "IPInfo: " $IPInfo
$data.project += @{"msg" = "Windows IP ���ã�"}
$data.project += @{"msg" = "   "}

# ��ȡ��������������
$netAdapters = Get-NetAdapter
# ������������������
foreach ($adapter in $netAdapters) {
    if ($adapter.Status) { # ֻ�������õ������� -eq "Up"
        $data.project += @{"msg" = "��̫�������� $($adapter.Name):"}
        $data.project += @{"msg" = "   �����ض��� DNS ��׺ . . . . . . . . . . . :"}
        # ��ȡ�������� IP ��ַ����
        $ipAddresses = Get-NetIPAddress -InterfaceAlias $adapter.InterfaceAlias
        foreach ($ip in $ipAddresses) {
            if ($ip.AddressFamily -eq "IPv6") {
                $data.project += @{"msg" = "   �������� IPv6 ��ַ. . . . . . . . . . . . . . : $($ip.IPAddress)"}
            } elseif ($ip.AddressFamily -eq "IPv4") {
                $data.project += @{"msg" = "   IPv4 ��ַ. . . . . . . . . . . . . . . . . . . : $($ip.IPAddress)"}
            }
        }
        
        # ��ȡ�����������������Ĭ������
        $defaultGateway = Get-NetRoute -InterfaceAlias $adapter.InterfaceAlias -DestinationPrefix '0.0.0.0/0' | Select-Object -First 1
        if ($defaultGateway) {
            $data.project += @{"msg" = "   Ĭ������. . . . . . . . . . . . . : $($defaultGateway.NextHop)"}
        } else {
            $data.project += @{"msg" = "   Ĭ������. . . . . . . . . . . . . :  "}
        }
        # TODO:���е�С������Ҫ����
        # #�����������  
        # $subnetMask = ($ipAddresses | Where-Object {$_.AddressFamily -eq "IPv4"} | Select-Object -ExpandProperty PrefixLength)
        # if ($subnetMask) {
        #     $data.project += @{"msg" ="   ��������  . . . . . . . . . . . . . :" + (Convert-MaskToSubnet $subnetMask)}
        # } else {
        #     $data.project += @{"msg" ="   ��������  . . . . . . . . . . . . . : "}
        # }

        #����
        $data.project += @{"msg" = "   "}
       
    }
}

# #net���
# $netInfo = Get-NetAdapter | Where-Object {$_.Status -eq "Up"}
# Write-Host "Network Adapter Status:"
# $data.project += @{"msg" = $netInfo} 

#ϵͳ��Ϣ���
$systemInfo = systemInfo
# echo  "SystemInfo: " $systeminfo
$data.project += @{"msg" = $systemInfo} 




# ��ȡ��ȫ���������ļ�
$config = Get-Content -path config.cfg
# echo $config

# ���������ļ�������������  
foreach ($line in $config) {  
    $config_line = $line -split "="  
    $key = $config_line[0].Trim()  
    $value = $config_line[1].Trim()  
    
    #[ϵͳ����]
    #��������ʹ�����޲���
    if ($key -eq "MaximumPasswordAge") {
        $msg = if ($value -eq "90") { "�����ʹ�����޲��Է��ϱ�׼"} else { "�����ʹ�����޲��Բ����ϱ�׼"}
        $msg = $msg + ":���ڲ��޸������������뱩¶����,����Ϊ�����ϵͳ�ı�����.��Ҫ��������ʹ������."
        $data.project += @{"msg" = $msg}  
    }

    #������볤����Сֵ����
    if ($key -eq "MinimumPasswordLength") {
        $msg = if ($value -eq "8") { "������Сֵ���Է��ϱ�׼"} else { "������Сֵ���Բ����ϱ�׼"}
        $msg = $msg + ":����С�Ŀ�����ڱ����Ƴ��ķ���,����Ϊ�˱�֤����İ�ȫ,��߱�������Ҫ��������С����"
        $data.project += @{"msg" = $msg}  
    }

    # ������븴���Բ���  
    if ($key -eq "PasswordComplexity") {  
        $msg = if ($value -eq "1") { "���븴���Բ��Է��ϱ�׼" } else { "���븴���Բ��Բ����ϱ�׼" }  
        $msg = $msg + ":��������ĸ�����ַ��������ͨ�����ֹ������õĹ������ɷ���."
        $data.project += @{"msg" = $msg}  
    } 

    # ���ǿ��������ʷ����
    if ($key -eq "PasswordHistorySize") {
        $msg = if ($value -eq "2") { "ǿ��������ʷ���Է��ϱ�׼"} else { "ǿ��������ʷ���Բ����ϱ�׼"}
        $msg = $msg + ":ǿ��������ʷ����˼��,ϵͳ���ס��ǰ��������ʷ,���޸������ʱ�򲻿�����ǰ��������ͬ,�޸���ͬ��������������ı�¶��."
        $data.project += @{"msg" = $msg}  
    }

    #����˻�������ֵ����
    if ($key -eq "LockoutBadCount") {
        $msg = if ($value -eq "8") { "�˻�������ֵ���Է��ϱ�׼"} else { "�˻�������ֵ���Բ����ϱ�׼"}
        $msg = $msg + ":�˰�ȫ����ȷ�������û��ʻ��������ĵ�¼����ʧ�ܵĴ���."
        $data.project += @{"msg" = $msg}  
    }

    # #����˻�����ʱ�����
    # if ($key -eq "ResetLockoutCount") {
    #     $msg = if ($value -eq "30") { "�˻�����ʱ����Է��ϱ�׼"} else { "�˻�����ʱ����Բ����ϱ�׼"}
    #     $msg = $msg + ":�û���¼ʧ�ܴ�������Ӧ�Է�������¼��������,��ֹ���뱻���Ƶ�����."
    #     $data.project += @{"msg" = $msg}  
    # }

    # #��鸴λ�˻�����������ʱ�����
    # if ($key -eq "LockoutDuratio") {
    #     $msg = if ($value -eq "30") { "��λ�˻�����������ʱ����Է��ϱ�׼"} else { "��λ�˻�����������ʱ����Բ����ϱ�׼"}
    #     $msg = $msg + ":�˰�ȫ����ȷ������״̬�ĳ���ʱ��,��λ�˻�������������ָȷ����¼����ʧ��֮��͵�¼����ʧ�ܼ���������λΪ 0 ��ʧ�ܵ�¼����֮ǰ�����ķ�����.��Ч��ΧΪ 1 �� 99,999 ����֮��"
    #     $data.project += @{"msg" = $msg}  
    # }

    #���*�´ε�¼��������������
    if ($key -eq "RequireLogonToChangePassword") {
        $msg = if ($value -eq "0") { "*�´ε�¼�������������Է��ϱ�׼"} else { "*�´ε�¼�������������Բ����ϱ�׼"}
        $data.project += @{"msg" = $msg}  
    }

    #���*ǿ�ƹ��ڲ���
    if ($key -eq "ForceLogoffWhenHourExpire") {
        $msg = if ($value -eq "0") { "*ǿ�ƹ��ڲ��Է��ϱ�׼" } else { "*ǿ�ƹ��ڲ��Բ����ϱ�׼" }
        $data.project += @{"msg" = $msg}  
    }

    #������Ա����
    if ($key -eq "NewAdministratorName") {
        $msg = if ($value -eq "Administrator") { "����Ա���Ʒ��ϱ�׼"} else { "����Ա���Ʋ����ϱ�׼"}
        $data.project += @{"msg" = $msg}  
    }

    #��������û�����
    if ($key -eq "NewGuestName") {
        $msg = if ($value -eq "Guest") { "�����û����Ʒ��ϱ�׼"} else { "�����û����Ʋ����ϱ�׼"}
        $data.project += @{"msg" = $msg}  
    }

    #���Administartor�˻�ͣ�ò���
    if ($key -eq "EnableAdminAccount") {
        $msg = if ($value -eq "1") { "Administartor�˻�ͣ�ò��Է��ϱ�׼"} else { "Administartor�˻�ͣ�ò��Բ����ϱ�׼"}
        $data.project += @{"msg" = $msg}  
    }

    # ���guest�˻�ͣ�ò���  
    if ($key -eq "EnableGuestAccount") {  
        $msg = if ($value -eq "1") { "guest�˻�ͣ�ò��Է��ϱ�׼" } else { "guest�˻�ͣ�ò��Բ����ϱ�׼" }  
        $data.project += @{"msg" = $msg}  
    }  
  
    # [�¼����]
    #���ϵͳ�¼�  ����Ƿ������Ը������
    if ($key -eq "AuditSystemEvents") {   
        $msg = if ($value -eq "3") { "���ϵͳ�¼����Է��ϱ�׼"} else { "���ϵͳ�¼����Բ����ϱ�׼"}
        $msg = $msg + ":�������Ŵ���ά���Ƿ����������ز����ٵ�����,�ʶ���־�ļ��������������Ϊ��Ҫ."
        $data.project += @{"msg" = $msg}
    }
    
    #��˵�¼�¼� ����Ƿ�����¼�¼����
    if ($key -eq "AuditLogonEvents") {   
        $msg = if ($value -eq "3") { "��˵�¼�¼����Է��ϱ�׼"} else { "��˵�¼�¼����Բ����ϱ�׼"}
        $msg = $msg + ":�������Ŵ���ά���Ƿ����������ز����ٵ�����,�ʶ���־�ļ��������������Ϊ��Ҫ."
        $data.project += @{"msg" = $msg}
    }

    #��˶������
    if ($key -eq "AuditObjectAccess") {   
        $msg = if ($value -eq "3") { "��˶�����ʲ��Է��ϱ�׼"} else { "��˶�����ʲ��Բ����ϱ�׼"}
        $msg = $msg + ":�������Ŵ���ά���Ƿ����������ز����ٵ�����,�ʶ���־�ļ��������������Ϊ��Ҫ."
        $data.project += @{"msg" = $msg}
    }

    #�����Ȩʹ��
    if ($key -eq "AuditPrivilegeUse") {   
        $msg = if ($value -eq "3") { "�����Ȩʹ�ò��Է��ϱ�׼"} else { "�����Ȩʹ�ò��Բ����ϱ�׼"}
        $msg = $msg + ":�������Ŵ���ά���Ƿ����������ز����ٵ�����,�ʶ���־�ļ��������������Ϊ��Ҫ."
        $data.project += @{"msg" = $msg}
    }

    #�����Ȩ����
    if ($key -eq "AuditPolicyChange") {   
        $msg = if ($value -eq "3") { "�����Ȩ���Ĳ��Է��ϱ�׼"} else { "�����Ȩ���Ĳ��Բ����ϱ�׼"}
        $data.project += @{"msg" = $msg}
    }

    #����˻�����
    if ($key -eq "AuditAccountManage") {   
        $msg = if ($value -eq "2") { "����˻�������Է��ϱ�׼"} else { "����˻�������Բ����ϱ�׼"} 
        $msg = $msg + ":�������Ŵ���ά���Ƿ����������ز����ٵ�����,�ʶ���־�ļ��������������Ϊ��Ҫ"  
        $data.project += @{"msg" = $msg}
    }
    
    #��˽��̸���
    if ($key -eq "AuditProcessTracking") {   
        $msg = if ($value -eq "2") { "��˽��̸��ٲ��Է��ϱ�׼"} else { "��˽��̸��ٲ��Բ����ϱ�׼"}
        $msg = $msg + ":�������Ŵ���ά���Ƿ����������ز����ٵ�����,�ʶ���־�ļ��������������Ϊ��Ҫ."
        $data.project += @{"msg" = $msg}
    }

    #���Ŀ¼�������
    if ($key -eq "AuditDSAccess") {   
        $msg = if ($value -eq "3") { "���Ŀ¼������ʲ��Է��ϱ�׼"} else { "���Ŀ¼������ʲ��Բ����ϱ�׼"}
        $msg = $msg + ":�������Ŵ���ά���Ƿ����������ز����ٵ�����,�ʶ���־�ļ��������������Ϊ��Ҫ."   
        $data.project += @{"msg" = $msg}
    }

    #����˻���¼�¼�
    if ($key -eq "AuditAccountLogon") {   
        $msg = if ($value -eq "2") { "����˻���¼�¼����Է��ϱ�׼"} else { "����˻���¼�¼����Բ����ϱ�׼"}   
        $msg = $msg + ":�������Ŵ���ά���Ƿ����������ز����ٵ�����,�ʶ���־�ļ��������������Ϊ��Ҫ."
        $data.project += @{"msg" = $msg}
    }


    # [��ȨȨ��]
    #��������ʴ˼��������
    if ($key -eq "SeNetworkLogonRight") {   
        $msg = if ($value -eq "*S-1-5-32-544,*S-1-5-32-545,*S-1-5-32-551") { "��������ʴ˼�������Է��ϱ�׼"} else { "��������ʴ˼�������Բ����ϱ�׼"}
        $data.project += @{"msg" = $msg}
    }  

    #����ϵͳԶ�̹ػ����԰�ȫ
    if ($key -eq "SeRemoteShutdownPrivilege") {
        $msg = if ($value -eq "*S-1-5-32-544") { "����ϵͳԶ�̹ػ����Է��ϱ�׼"} else { "����ϵͳԶ�̹ػ����Բ����ϱ�׼"}
        $msg = $msg + "������Զ�˹ر�ϵͳ���˻���������ǹ���ԱȨ�޺���,����Ϊ�����ϵͳ�Ŀɿ���,��Ҫ����Ƿ����ƹر�ϵͳ���˻�����."
        $data.project += @{"msg" = $msg}  
    }

    #����ϵͳ���عػ����԰�ȫ ���ɹر�ϵͳ���ʻ�����
    if ($key -eq "SeShutdownPrivilege") {
        $msg = if ($value -eq "*S-1-5-32-544") { "����ϵͳ���عػ����Է��ϱ�׼"} else { "����ϵͳ���عػ����Բ����ϱ�׼"}
        $msg = $msg + "�����Թر�ϵͳ���˻���������ǹ���ԱȨ�޺���,����Ϊ�����ϵͳ�Ŀɿ���,��Ҫ����Ƿ����ƹر�ϵͳ���˻�����."
        $data.project += @{"msg" = $msg}  
    }

    #ȡ���ļ����������������Ȩ�޲���
    if ($key -eq "SeProfileSingleProcessPrivilege") {
        $msg = if ($value -eq "*S-1-5-32-544") { "ȡ���ļ����������������Ȩ�޲��Է��ϱ�׼"} else { "ȡ���ļ����������������Ȩ�޲��Բ����ϱ�׼"}
        $msg = $msg + "��������û�Ȩ�޿��ܻ������ȫ����. ���ڶ���������߿�����ȫ��������,��˽��������ε��û�������û�Ȩ��."
        $data.project += @{"msg" = $msg}  
    }



    # [ע���ֵ]
    #����Զ�̷��ʵ�ע���·������·��
    if ($key -eq "MACHINE\System\CurrentControlSet\Control\SecurePipeServers\Winreg\AllowedExactPaths\Machine") {
        $config_line = $value -split ","
        $value = $config_line[1].Trim() 
        $data.project += @{"msg" = $value}
    }

    # #����Ƿ���ɾ�����������ʵĹ���������ܵ�
    # if ($key -eq "MACHINE\SYSTEM\ControlSet001\services\LanmanServer\Parameters\NullSessionPipes") {
    #     $config_line = $value -split ","
    #     $value = $config_line[1].Trim()
    #     if ($value -like " "){
    #         $data.project += @{"msg" = "��ֵ"}
    #     }
    #     else {
    #         $data.project += @{"msg" = $value}
    #     }
    # }

  

    #��ͣ�Ựǰ����Ŀ���ʱ��
    if ($key -eq "MACHINE\System\CurrentControlSet\Services\LanManServer\Parameters\AutoDisconnect") {
	    $config_line = $value -split ","
        # echo $config_line
        $value = $config_line[1].Trim() 
        $msg = if ([int]$value -le "30") { "��ͣ�Ựǰ����Ŀ���ʱ����Է��ϱ�׼"} else { "��ͣ�Ựǰ����Ŀ���ʱ����Բ����ϱ�׼"}
        $data.project += @{"msg" = $msg}
    }

    #����Ƿ�������SAM�����û�����
    if ($key -eq "MACHINE\SYSTEM\CurrentControlSet\Control\Lsa\Restrictanonymous") {
        $config_line = $value -split ","
        $value = $config_line[1].Trim()
        $msg = if ($value -eq "1") { "������SAM�����û����ӷ��ϱ�׼"} else{"������SAM�����û����Ӳ�����Ҫ��"}
        $msg = $msg + "����Ȩ���û����������г��˻���,�����罻���̹��ƻ��Բ²����뵽����."
        $data.project += @{"msg" = $msg}
    }

    #����Ƿ�������SAM�����û�����2
    if ($key -eq "MACHINE\SYSTEM\CurrentControlSet\Control\Lsa\RestrictanonymousSAM") {
        $config_line = $value -split ","
        $value = $config_line[1].Trim()
        $msg = if ($value -eq "1") { "������SAM�����û�����2���ϱ�׼"} else{"������SAM�����û�����2������Ҫ��"}
        $msg = $msg + "����Ȩ���û����������г��˻���,�����罻���̹��ƻ��Բ²����뵽����."
        $data.project += @{"msg" = $msg}
    }


}

# ����һ����������鲢��¼��ȫ����״̬  
function CheckSecurityPolicy($registryKey, $policyName, $condition, $expectedValue, $compliantMessage, $nonCompliantMessage) {  
    $policyStatus = (Get-ItemProperty -Path "Registry::$registryKey" -ErrorAction Stop).$policyName     
    $status = switch ($condition) { 
        '-eq' { if ($policyStatus -eq $expectedValue) { "1" } else { "0" } }
        '-le' { if ($policyStatus -le $expectedValue) { '1' } else { '0' } }  
        '-ge' { if ($policyStatus -ge $expectedValue) { '1' } else { '0' } }  
        default { throw "Unsupported condition: $condition" }  
    }  
    $message = if ($status -eq "1") { $compliantMessage } else { $nonCompliantMessage }  
    $projectData = @{"code" = $status; "msg" = $message}  
    $data['project'] += $projectData  
}  


#���ϵͳ��־�ļ��ﵽ����Сʱ�Ķ��������
CheckSecurityPolicy 'HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\services\eventlog\System' 'Retention' '-eq' '0' 'ϵͳ��־�ļ��ﵽ����Сʱ�Ķ�������ŷ���Ҫ��' 'ϵͳ��־�ļ��ﵽ����Сʱ�Ķ�������Ų�����Ҫ��'

# Ӧ����־�鿴����С����  
CheckSecurityPolicy 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Eventlog\Application' 'MaxSize' '-eq' '8192' 'Ӧ����־�鿴����С���ò��Է��ϱ�׼' 'Ӧ����־�鿴����С���ò��Բ����ϱ�׼'  
  
#ϵͳ��־�鿴����С����
CheckSecurityPolicy 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Eventlog\System' 'MaxSize' '-eq' '8192' 'ϵͳ��־�鿴����С���ò��Է��ϱ�׼' 'ϵͳ��־�鿴����С���ò��Բ����ϱ�׼'

#��ȫ��־�鿴����С����
CheckSecurityPolicy 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Eventlog\Security' 'MaxSize' '-eq' '8192' '��ȫ��־�鿴����С���ò��Է��ϱ�׼' '��ȫ��־�鿴����С���ò��Բ����ϱ�׼'

#����Ƿ��ѿ���Windows����ǽ
CheckSecurityPolicy 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile' 'EnableFirewall' '-eq' '1' 'Windows����ǽ���ϱ�׼' 'Windows����ǽ������Ҫ��'

#����Ƿ�������SYN��������
CheckSecurityPolicy 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\Tcpip\Parameters' 'SynAttackProtect' '-eq' '1' 'SYN�����������ϱ�׼' 'SYN�������������ϱ�׼'
#SYN ���������� TCP/IP ���ӽ��������еİ�ȫ©��.Ҫʵʩ SYN ��ˮ����,�����߻�ʹ�ó����ʹ��� TCP SYN �����������������ϵĹ������Ӷ���

#���TCP����������ֵ
CheckSecurityPolicy 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\Tcpip\Parameters' 'TcpMaxPortsExhausted' '-eq' '5' 'TCP����������ֵ���ϱ�׼' 'TCP����������ֵ�����ϱ�׼'

#���ȡ��������Ӧ SYN ����֮ǰҪ���´��� SYN-ACK �Ĵ���
CheckSecurityPolicy 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\Tcpip\Parameters' 'TcpMaxConnectResponseRetransmissions' '-eq' '2' 'ȡ��������Ӧ SYN ����֮ǰҪ���´��� SYN-ACK �Ĵ������ϱ�׼' 'ȡ��������Ӧ SYN ����֮ǰҪ���´��� SYN-ACK �Ĵ��������ϱ�׼'

#��鴦��SYN_RCVD ״̬�µ� TCP ������ֵ
CheckSecurityPolicy 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\Tcpip\Parameters' 'TcpMaxHalfOpen' '-eq' '500' '����SYN_RCVD ״̬�µ� TCP ������ֵ���ϱ�׼' '����SYN_RCVD ״̬�µ� TCP ������ֵ�����ϱ�׼'

#��鴦��SYN_RCVD ״̬��,�������Ѿ�������һ�����´����TCP������ֵ
CheckSecurityPolicy 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\Tcpip\Parameters' 'TcpMaxHalfOpenRetried' '-eq' '400' '����SYN_RCVD ״̬��,�������Ѿ�������һ�����´����TCP������ֵ���ϱ�׼' '����SYN_RCVD ״̬��,�������Ѿ�������һ�����´����TCP������ֵ�����ϱ�׼'

#����Ƿ������ò���ȷ����ICMP��������
CheckSecurityPolicy 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\Tcpip\Parameters' 'EnableICMPRedirect' '-eq' '0' '����Ƿ������ò���ȷ����ICMP�����������ϱ�׼' '����Ƿ������ò���ȷ����ICMP�������������ϱ�׼'

# ����Ƿ��ѽ���ʧЧ���ؼ��
CheckSecurityPolicy 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\Tcpip\Parameters' 'EnableDeadGWDetect' '-eq' '0' '�Ƿ��ѽ���ʧЧ���ؼ����ϱ�׼' '�Ƿ��ѽ���ʧЧ���ؼ�ⲻ���ϱ�׼'

# ����Ƿ�����ȷ�����ش���������Ƭ�εĴ���
CheckSecurityPolicy 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\Tcpip\Parameters' 'TcpMaxDataRetransmissions' '-eq' '2' '�Ƿ�����ȷ�����ش���������Ƭ�εĴ������ϱ�׼' '����Ƿ�����ȷ�����ش���������Ƭ�εĴ��������ϱ�׼'

# ����Ƿ��ѽ���·�ɷ��ֹ���
CheckSecurityPolicy 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters' 'PerformRouterDiscovery' '-eq' '0' '�Ƿ��ѽ���·�ɷ��ֹ��ܷ��ϱ�׼' '�Ƿ��ѽ���·�ɷ��ֹ��ܲ����ϱ�׼'

# ����Ƿ�����ȷ����TCP���Ӵ��ʱ��
CheckSecurityPolicy 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters' 'KeepAliveTime' '-eq' '300000' '�Ƿ�����ȷ����TCP���Ӵ��ʱ����ϱ�׼' '�Ƿ�����ȷ����TCP���Ӵ��ʱ�䲻���ϱ�׼'

# ����Ƿ������ò���ȷ����TCP��Ƭ��������
CheckSecurityPolicy 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters' 'EnablePMTUDiscovery' '-eq' '0' '�Ƿ������ò���ȷ����TCP��Ƭ�����������ϱ�׼' '�Ƿ������ò���ȷ����TCP��Ƭ�������������ϱ�׼'

# ����Ƿ�������"����ʾ�����û���"����
CheckSecurityPolicy 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' 'Dontdisplaylastusername' '-eq' '1' '����Ƿ�������"����ʾ�����û���"���Է��ϱ�׼' '����Ƿ�������"����ʾ�����û���"���Բ����ϱ�׼'          

# ����Ƿ�����ȷ����"��ʾ�û����������֮ǰ���и���"����
CheckSecurityPolicy 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' 'PasswordExpiryWarning' '-eq' '14' '����Ƿ�����ȷ����"��ʾ�û����������֮ǰ���и���"���Է��ϱ�׼' '����Ƿ�����ȷ����"��ʾ�û����������֮ǰ���и���"���Բ����ϱ�׼'

# ��������Ựʱ��ʾ�û���Ϣ  
CheckSecurityPolicy 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' 'DontDisplayLockedUserId' '-eq' '3' '����Ƿ�����ȷ����"�����Ựʱ��ʾ�û���Ϣ"���Է��ϱ�׼' '����Ƿ�����ȷ����"�����Ựʱ��ʾ�û���Ϣ"���Բ����ϱ�׼'  
  
# ����Ƿ��ѽ���WindowsӲ��Ĭ�Ϲ���  
CheckSecurityPolicy 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters' 'AutoShareServer' '-eq' '0' '����Ƿ��ѽ���WindowsӲ��Ĭ�Ϲ�����ϱ�׼' '����Ƿ��ѽ���WindowsӲ��Ĭ�Ϲ������ϱ�׼'  
  
# ����Ƿ��ѽ���WindowsӲ��Ĭ�Ϲ���2  
CheckSecurityPolicy 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters' 'AutoShareWks' '-eq' '0' '����Ƿ��ѽ���WindowsӲ��Ĭ�Ϲ���2���ϱ�׼' '����Ƿ��ѽ���WindowsӲ��Ĭ�Ϲ���2�����ϱ�׼'

#��Ļ�Զ���������
CheckSecurityPolicy 'HKEY_CURRENT_USER\Control Panel\Desktop' 'ScreenSaveActive' '-eq' '1' '��Ļ�Զ�����������ϱ�׼' '��Ļ�Զ��������򲻷��ϱ�׼'

#��Ļ������������ʱ��
CheckSecurityPolicy 'HKEY_CURRENT_USER\Control Panel\Desktop' 'ScreenSaveTimeout' '-le' '600' '��Ļ������������ʱ����ϱ�׼' '��Ļ������������ʱ�䲻���ϱ�׼'

#��Ļ�ָ�ʱʹ�����뱣��
CheckSecurityPolicy 'HKEY_CURRENT_USER\Control Panel\Desktop' 'ScreenSaveTimeOut' '-ge' '1' '��Ļ�ָ�ʱʹ�����뱣�����ϱ�׼' '��Ļ�ָ�ʱʹ�����뱣�������ϱ�׼'

#�Ƿ�����NTP����ͬ��ʱ��
CheckSecurityPolicy 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W32time\TimeProviders\NtpServer' 'Enabled' '-eq' '1' '����NTP����ͬ��ʱ�Ӳ��Է��ϱ�׼' '����NTP����ͬ��ʱ�Ӳ��Բ����ϱ�׼'

# ���ر�Ĭ�Ϲ�����  
CheckSecurityPolicy 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa' 'restrictanonymous' '-eq' '1' '�ر�Ĭ�Ϲ����̲��Է��ϱ�׼' '�ر�Ĭ�Ϲ����̲��Բ����ϱ�׼'  
  
# ��ֹȫ���������Զ�����  
CheckSecurityPolicy 'HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer' 'NoDriveTypeAutoRun' '-eq' '255' '��ֹȫ���������Զ����ŷ��ϱ�׼' '��ֹȫ���������Զ����Ų����ϱ�׼'  

#����Ƿ���ȷ���÷���������ͣ�Ựǰ����Ŀ���ʱ����
CheckSecurityPolicy 'HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\services\LanmanServer\Parameters' 'Autodisconnect' '-eq' '15' '����Ƿ���ȷ���÷���������ͣ�Ựǰ����Ŀ���ʱ�������ϱ�׼' '����Ƿ���ȷ���÷���������ͣ�Ựǰ����Ŀ���ʱ���������ϱ�׼'

# ����Ƿ�������"����¼ʱ������ʱ�Զ�ע���û�"����
CheckSecurityPolicy 'HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\services\LanmanServer\Parameters' 'Enableforcedlogoff' '-eq' '1' '����Ƿ�������"����¼ʱ������ʱ�Զ�ע���û�"���Է��ϱ�׼' '����Ƿ�������"����¼ʱ������ʱ�Զ�ע���û�"���Բ����ϱ�׼'

# ����Ƿ��ѽ���"��¼ʱ���밴 Ctrl+Alt+Del"����
CheckSecurityPolicy 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' 'Disablecad' '-eq' '0' '����Ƿ��ѽ���"��¼ʱ���밴 Ctrl+Alt+Del"���Է��ϱ�׼' '����Ƿ��ѽ���"��¼ʱ���밴 Ctrl+Alt+Del"���Բ����ϱ�׼'

#����Ƿ��ѽ�ֹWindows�Զ���¼
CheckSecurityPolicy 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' 'AutoAdminLogon' '-eq' '0' '����Ƿ��ѽ�ֹWindows�Զ���¼���ϱ�׼' '����Ƿ��ѽ�ֹWindows�Զ���¼�����ϱ�׼'

#�򻷾�������Ƿ�����ȷ����"�ɱ����汣��ĵ�¼�ĸ���"����
CheckSecurityPolicy 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' 'CachedLogonsCount' '-eq' '5' '�򻷾�������Ƿ�����ȷ����"�ɱ����汣��ĵ�¼�ĸ���"���Է��ϱ�׼' '�򻷾�������Ƿ�����ȷ����"�ɱ����汣��ĵ�¼�ĸ���"���Բ����ϱ�׼'


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


