// 获取DOM元素
        const downloadAllBtn = document.getElementById('downloadAllBtn');
        const singleDownloadBtns = document.querySelectorAll('.download-single');
        const statusMessage = document.getElementById('statusMessage');
        
        // 单个下载函数
        function downloadFile(url, name) {
            try {
                // 创建隐藏的a标签来触发下载
                const link = document.createElement('a');
                link.href = url;
                link.download = name || url.split('/').pop();
                link.target = '_blank';
                document.body.appendChild(link);
                link.click();
                document.body.removeChild(link);
                return true;
            } catch (error) {
                console.error(`下载${name}失败:`, error);
                return false;
            }
        }
        
        // 一键下载全部
        downloadAllBtn.addEventListener('click', function() {
            // 清空状态提示
            statusMessage.className = 'status';
            statusMessage.textContent = '';
            
            let successCount = 0;
            let totalCount = singleDownloadBtns.length;
            
            // 遍历所有下载按钮，触发下载
            singleDownloadBtns.forEach((btn, index) => {
                const url = btn.getAttribute('data-url');
                const name = btn.closest('.software-item').querySelector('.software-name').textContent;
                
                // 延迟下载，避免浏览器限制
                setTimeout(() => {
                    if (downloadFile(url, name)) {
                        successCount++;
                    }
                    
                    // 所有下载完成后显示状态
                    if (index === totalCount - 1) {
                        setTimeout(() => {
                            if (successCount === totalCount) {
                                statusMessage.className = 'status success';
                                statusMessage.textContent = `✅ 全部${totalCount}个软件下载任务已触发！请检查浏览器下载栏。`;
                            } else {
                                statusMessage.className = 'status error';
                                statusMessage.textContent = `⚠️ 仅成功触发${successCount}/${totalCount}个软件下载，部分下载可能失败。`;
                            }
                        }, 1000);
                    }
                }, index * 500); // 每个下载间隔500ms
            });
            
            // 提示用户
            statusMessage.className = 'status success';
            statusMessage.textContent = '🚀 正在触发所有软件下载，请稍候...';
        });
        
        // 单个软件下载
        singleDownloadBtns.forEach(btn => {
            btn.addEventListener('click', function() {
                // 清空状态提示
                statusMessage.className = 'status';
                statusMessage.textContent = '';
                
                const url = this.getAttribute('data-url');
                const name = this.closest('.software-item').querySelector('.software-name').textContent;
                
                if (downloadFile(url, name)) {
                    statusMessage.className = 'status success';
                    statusMessage.textContent = `✅ ${name}下载任务已触发！`;
                } else {
                    statusMessage.className = 'status error';
                    statusMessage.textContent = `❌ ${name}下载失败，请重试！`;
                }
            });
        });