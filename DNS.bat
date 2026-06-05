@echo off
title DNS管理工具
setlocal enabledelayedexpansion

:menu
cls
echo ================================
echo       DNS 管理工具
echo ================================
echo [1] 查看DNS信息
echo [2] 查看网络信息
echo [3] 查看局域网信息
echo [4] 切换DNS服务器
echo [5] 恢复自动获取
echo [6] 刷新DNS缓存
echo [0] 退出
echo ================================
set /p choice=请选择(0-6):

if "%choice%"=="1" goto view
if "%choice%"=="2" goto network
if "%choice%"=="3" goto lan
if "%choice%"=="4" goto switch
if "%choice%"=="5" goto auto
if "%choice%"=="6" goto flush
if "%choice%"=="0" exit
goto menu

:view
cls
echo ================================
echo       当前DNS信息
echo ================================
echo.

for /f "tokens=1,2" %%i in ('netsh interface ip show config ^| find "接口"') do (
    echo 网卡名称: %%j
    echo ----------------------------------------
    netsh interface ip show dns "%%j"
    echo.
)

echo ================================
echo 按任意键返回菜单...
pause >nul
goto menu

:network
cls
echo ================================
echo       网络详细信息
echo ================================
echo.

:: 获取所有网卡信息
for /f "tokens=1,2" %%i in ('netsh interface ip show config ^| find "接口"') do (
    echo 【网卡: %%j】
    echo ----------------------------------------
    netsh interface ip show config "%%j" | findstr /v "^$" | findstr /v "配置"
    echo.
)

echo ================================
echo 按任意键返回菜单...
pause >nul
goto menu

:lan
cls
echo ================================
echo       局域网信息
echo ================================
echo.

:: 获取本机IP信息
echo 【本机网络信息】
echo ----------------------------------------
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /i "IPv4"') do (
    echo 本机IPv4地址:%%a
)
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /i "默认网关"') do (
    echo 默认网关:%%a
)
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /i "子网掩码"') do (
    echo 子网掩码:%%a
)
echo.

:: 获取局域网内其他设备
echo 【局域网内设备】
echo ----------------------------------------
echo 正在扫描局域网设备，请稍候...
set "gateway="
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /i "默认网关"') do (
    set "gateway=%%a"
    goto :scan
)

:scan
if "%gateway%"=="" goto :arpscan

:: 提取网段
for /f "tokens=1-3 delims=." %%a in ("%gateway%") do (
    set "network=%%a.%%b.%%c"
)

echo 网段: %network%.0/24
echo.
echo IP地址         MAC地址                状态
echo ----------------------------------------
arp -a | findstr /i "%network%" | findstr /v "ff-ff-ff" | findstr /v "组播"

echo.
echo 【网络连接状态】
echo ----------------------------------------
netstat -an | findstr "ESTABLISHED" | find /c ":" > temp.txt
set /p connections=<temp.txt
del temp.txt
echo 当前已建立的连接数: %connections%

echo.
echo 【DNS缓存统计】
ipconfig /displaydns | find /c "Record Name" > temp.txt
set /p dnscount=<temp.txt
del temp.txt
echo DNS缓存条目数: %dnscount%

echo ================================
echo 按任意键返回菜单...
pause >nul
goto menu

:switch
cls
echo ================================
echo       选择DNS服务器
echo ================================
echo 【国外DNS】
echo [1] Google DNS (8.8.8.8/8.8.4.4)
echo [2] Cloudflare (1.1.1.1/1.0.0.1)
echo [3] OpenDNS (208.67.222.222/208.67.220.220)
echo [4] Quad9 (9.9.9.9/149.112.112.112)
echo [5] Verisign (64.6.64.6/64.6.65.6)
echo [6] Comodo (8.26.56.26/8.20.247.20)
echo [7] DNS.WATCH (84.200.69.80/84.200.70.40)
echo [8] Yandex (77.88.8.8/77.88.8.1)
echo.
echo 【国内DNS】
echo [9] 阿里 DNS (223.5.5.5/223.6.6.6)
echo [10] 114 DNS (114.114.114.114/114.114.115.115)
echo [11] 腾讯 DNS (119.29.29.29)
echo [12] 百度 DNS (180.76.76.76)
echo [13] 360 DNS (101.226.4.6/218.30.118.6)
echo [14] 中国电信 (101.226.4.6)
echo [15] CNNIC (1.2.4.8/210.2.4.8)
echo.
echo 【安全DNS】
echo [16] AdGuard (94.140.14.14/94.140.15.15)
echo [17] 防钓鱼 (156.154.70.25/156.154.71.25)
echo [18] 家庭保护 (156.154.70.3/156.154.71.3)
echo.
echo 【其他】
echo [19] 自定义DNS
echo [20] 查看当前DNS
echo [21] 返回主菜单
echo ================================
set /p dns_choice=请选择(1-21):

if "%dns_choice%"=="1" goto set_google
if "%dns_choice%"=="2" goto set_cf
if "%dns_choice%"=="3" goto set_opendns
if "%dns_choice%"=="4" goto set_quad9
if "%dns_choice%"=="5" goto set_verisign
if "%dns_choice%"=="6" goto set_comodo
if "%dns_choice%"=="7" goto set_watch
if "%dns_choice%"=="8" goto set_yandex
if "%dns_choice%"=="9" goto set_ali
if "%dns_choice%"=="10" goto set_114
if "%dns_choice%"=="11" goto set_tencent
if "%dns_choice%"=="12" goto set_baidu
if "%dns_choice%"=="13" goto set_360
if "%dns_choice%"=="14" goto set_chinatelecom
if "%dns_choice%"=="15" goto set_cnnic
if "%dns_choice%"=="16" goto set_adguard
if "%dns_choice%"=="17" goto set_antiphish
if "%dns_choice%"=="18" goto set_family
if "%dns_choice%"=="19" goto custom_dns
if "%dns_choice%"=="20" goto view
if "%dns_choice%"=="21" goto menu
goto switch

:set_google
echo 正在设置 Google DNS...
for /f "tokens=1,2" %%i in ('netsh interface ip show config ^| find "接口"') do (
    netsh interface ip set dns name="%%j" source=static addr=8.8.8.8
    netsh interface ip add dns name="%%j" addr=8.8.4.4 index=2
)
ipconfig /flushdns >nul
echo 完成！已切换到 Google DNS (8.8.8.8)
pause
goto switch

:set_cf
echo 正在设置 Cloudflare DNS...
for /f "tokens=1,2" %%i in ('netsh interface ip show config ^| find "接口"') do (
    netsh interface ip set dns name="%%j" source=static addr=1.1.1.1
    netsh interface ip add dns name="%%j" addr=1.0.0.1 index=2
)
ipconfig /flushdns >nul
echo 完成！已切换到 Cloudflare DNS (1.1.1.1)
pause
goto switch

:set_opendns
echo 正在设置 OpenDNS...
for /f "tokens=1,2" %%i in ('netsh interface ip show config ^| find "接口"') do (
    netsh interface ip set dns name="%%j" source=static addr=208.67.222.222
    netsh interface ip add dns name="%%j" addr=208.67.220.220 index=2
)
ipconfig /flushdns >nul
echo 完成！已切换到 OpenDNS
pause
goto switch

:set_quad9
echo 正在设置 Quad9 DNS...
for /f "tokens=1,2" %%i in ('netsh interface ip show config ^| find "接口"') do (
    netsh interface ip set dns name="%%j" source=static addr=9.9.9.9
    netsh interface ip add dns name="%%j" addr=149.112.112.112 index=2
)
ipconfig /flushdns >nul
echo 完成！已切换到 Quad9 DNS (9.9.9.9)
pause
goto switch

:set_verisign
echo 正在设置 Verisign DNS...
for /f "tokens=1,2" %%i in ('netsh interface ip show config ^| find "接口"') do (
    netsh interface ip set dns name="%%j" source=static addr=64.6.64.6
    netsh interface ip add dns name="%%j" addr=64.6.65.6 index=2
)
ipconfig /flushdns >nul
echo 完成！已切换到 Verisign DNS
pause
goto switch

:set_comodo
echo 正在设置 Comodo DNS...
for /f "tokens=1,2" %%i in ('netsh interface ip show config ^| find "接口"') do (
    netsh interface ip set dns name="%%j" source=static addr=8.26.56.26
    netsh interface ip add dns name="%%j" addr=8.20.247.20 index=2
)
ipconfig /flushdns >nul
echo 完成！已切换到 Comodo DNS
pause
goto switch

:set_watch
echo 正在设置 DNS.WATCH...
for /f "tokens=1,2" %%i in ('netsh interface ip show config ^| find "接口"') do (
    netsh interface ip set dns name="%%j" source=static addr=84.200.69.80
    netsh interface ip add dns name="%%j" addr=84.200.70.40 index=2
)
ipconfig /flushdns >nul
echo 完成！已切换到 DNS.WATCH
pause
goto switch

:set_yandex
echo 正在设置 Yandex DNS...
for /f "tokens=1,2" %%i in ('netsh interface ip show config ^| find "接口"') do (
    netsh interface ip set dns name="%%j" source=static addr=77.88.8.8
    netsh interface ip add dns name="%%j" addr=77.88.8.1 index=2
)
ipconfig /flushdns >nul
echo 完成！已切换到 Yandex DNS
pause
goto switch

:set_ali
echo 正在设置 阿里 DNS...
for /f "tokens=1,2" %%i in ('netsh interface ip show config ^| find "接口"') do (
    netsh interface ip set dns name="%%j" source=static addr=223.5.5.5
    netsh interface ip add dns name="%%j" addr=223.6.6.6 index=2
)
ipconfig /flushdns >nul
echo 完成！已切换到 阿里 DNS
pause
goto switch

:set_114
echo 正在设置 114 DNS...
for /f "tokens=1,2" %%i in ('netsh interface ip show config ^| find "接口"') do (
    netsh interface ip set dns name="%%j" source=static addr=114.114.114.114
    netsh interface ip add dns name="%%j" addr=114.114.115.115 index=2
)
ipconfig /flushdns >nul
echo 完成！已切换到 114 DNS
pause
goto switch

:set_tencent
echo 正在设置 腾讯 DNS...
for /f "tokens=1,2" %%i in ('netsh interface ip show config ^| find "接口"') do (
    netsh interface ip set dns name="%%j" source=static addr=119.29.29.29
)
ipconfig /flushdns >nul
echo 完成！已切换到 腾讯 DNS
pause
goto switch

:set_baidu
echo 正在设置 百度 DNS...
for /f "tokens=1,2" %%i in ('netsh interface ip show config ^| find "接口"') do (
    netsh interface ip set dns name="%%j" source=static addr=180.76.76.76
)
ipconfig /flushdns >nul
echo 完成！已切换到 百度 DNS
pause
goto switch

:set_360
echo 正在设置 360 DNS...
for /f "tokens=1,2" %%i in ('netsh interface ip show config ^| find "接口"') do (
    netsh interface ip set dns name="%%j" source=static addr=101.226.4.6
    netsh interface ip add dns name="%%j" addr=218.30.118.6 index=2
)
ipconfig /flushdns >nul
echo 完成！已切换到 360 DNS
pause
goto switch

:set_chinatelecom
echo 正在设置 中国电信 DNS...
for /f "tokens=1,2" %%i in ('netsh interface ip show config ^| find "接口"') do (
    netsh interface ip set dns name="%%j" source=static addr=101.226.4.6
)
ipconfig /flushdns >nul
echo 完成！已切换到 中国电信 DNS
pause
goto switch

:set_cnnic
echo 正在设置 CNNIC DNS...
for /f "tokens=1,2" %%i in ('netsh interface ip show config ^| find "接口"') do (
    netsh interface ip set dns name="%%j" source=static addr=1.2.4.8
    netsh interface ip add dns name="%%j" addr=210.2.4.8 index=2
)
ipconfig /flushdns >nul
echo 完成！已切换到 CNNIC DNS
pause
goto switch

:set_adguard
echo 正在设置 AdGuard DNS (去广告)...
for /f "tokens=1,2" %%i in ('netsh interface ip show config ^| find "接口"') do (
    netsh interface ip set dns name="%%j" source=static addr=94.140.14.14
    netsh interface ip add dns name="%%j" addr=94.140.15.15 index=2
)
ipconfig /flushdns >nul
echo 完成！已切换到 AdGuard DNS (可拦截广告)
pause
goto switch

:set_antiphish
echo 正在设置 防钓鱼 DNS...
for /f "tokens=1,2" %%i in ('netsh interface ip show config ^| find "接口"') do (
    netsh interface ip set dns name="%%j" source=static addr=156.154.70.25
    netsh interface ip add dns name="%%j" addr=156.154.71.25 index=2
)
ipconfig /flushdns >nul
echo 完成！已切换到 防钓鱼 DNS (拦截恶意网站)
pause
goto switch

:set_family
echo 正在设置 家庭保护 DNS...
for /f "tokens=1,2" %%i in ('netsh interface ip show config ^| find "接口"') do (
    netsh interface ip set dns name="%%j" source=static addr=156.154.70.3
    netsh interface ip add dns name="%%j" addr=156.154.71.3 index=2
)
ipconfig /flushdns >nul
echo 完成！已切换到 家庭保护 DNS (拦截成人内容)
pause
goto switch

:custom_dns
cls
echo ================================
echo       自定义DNS
echo ================================
echo.
set /p custom_dns1=请输入主DNS地址 (如: 8.8.8.8): 
set /p custom_dns2=请输入备用DNS地址 (直接回车跳过): 

echo 正在设置自定义 DNS...
for /f "tokens=1,2" %%i in ('netsh interface ip show config ^| find "接口"') do (
    netsh interface ip set dns name="%%j" source=static addr=%custom_dns1%
    if not "%custom_dns2%"=="" netsh interface ip add dns name="%%j" addr=%custom_dns2% index=2
)
ipconfig /flushdns >nul
echo 完成！已切换到自定义 DNS (%custom_dns1%)
pause
goto switch

:auto
echo 正在恢复自动获取DNS...
for /f "tokens=1,2" %%i in ('netsh interface ip show config ^| find "接口"') do (
    netsh interface ip set dns name="%%j" source=dhcp
)
ipconfig /flushdns >nul
echo 完成！已恢复自动获取
pause
goto menu

:flush
echo 正在刷新DNS缓存...
ipconfig /flushdns
echo DNS缓存已刷新
echo 提示：如果网页打不开，请重启浏览器
pause
goto menu