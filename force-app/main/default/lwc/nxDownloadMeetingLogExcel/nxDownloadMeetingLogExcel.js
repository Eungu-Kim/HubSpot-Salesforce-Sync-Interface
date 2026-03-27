import { LightningElement, api, track } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import sheetjs from '@salesforce/resourceUrl/sheetjsStyle';
import { templateContents } from './referSheet.js';
import FORM_FACTOR from '@salesforce/client/formFactor';
import getEvents from '@salesforce/apex/NX_DownloadMeetingLogExcelController.getEvents';

export default class NxDownloadMeetingLogExcel extends LightningElement {
    @api recordId
    @api isListView = false;
    @track excelData = [];
    @track recordData = [];
    limitSize = 200;
    isLoaded = false;

    dateStr = new Date().toISOString().slice(0, 10);

    async connectedCallback() {
        console.log('lwc connectedCallback 시작');
        // PC 화면에서만 다운로드 가능
        if(FORM_FACTOR == 'Large') {
            try {
                this.isLoaded = true;
                await loadScript(this, sheetjs);
                console.log('라이브러리 로드 성공');
            } catch(error) {
                console.error('라이브러리 로드 실패', error);
            } finally {
                this.isLoaded = false;
            }
        }
    }

    // 상세 페이지용 Excel Download
    // async handleExcelDownload() {
    //     this.isLoaded = true;
    //     this.recordData = [];

    //     try {
    //         await this.fetchData(null, null);

    //         if(this.recordData.length > 0) {
    //             this.generateExcel();
    //         } else {
    //             alert('데이터가 없습니다.');
    //         }
    //     } catch(error) {
    //         console.log('error');
    //     } finally {
    //         this.isLoaded = false;
    //     }
    // }

    async fetchData(lastId, lastDate) {
        const result = await getEvents({
            recordId: null,
            lastRecordId: lastId,
            lastCreatedDate: lastDate,
            limitSize: this.limitSize
        });
        
        if(result && result.length > 0) {
            this.recordData.push(...result);
            if(result.length === this.limitSize) {
                const lastRow = result[result.length - 1];
                await this.fetchData(lastRow.Id, lastRow.CreatedDate);
            }
        }
    }

    @api
    async handleExcelDownloadList(target, pushArray) {
        if(FORM_FACTOR !== 'Large') {
            alert('모바일 화면에서는 다운로드가 불가합니다. PC에서 진행해주세요.');
            return;
        }

        try {
            console.log('handleExcelDownloadList 라이브러리 로드 시작');
            this.isLoaded = true;
            await loadScript(this, sheetjs);

            this.recordData = [];
            if (Array.isArray(pushArray) && pushArray.length > 0) {
                this.recordData = pushArray;
            } else {
                await this.fetchData(null, null);
            }

            if(this.recordData.length === 0) {
                alert('데이터가 없습니다.');
                return;
            }
            
            let dataArray = [...templateContents.excelTemplate];

            this.recordData.forEach(item => {
                dataArray.push([
                    item.Name || '',
                    item.Task__c || '',
                    item.SoldTo2__c || '',
                    item.StartNotAllDay__c || item.StartAllDay__c || '',
                    item.EndNotAllDay__c || item.EndAllDay__c || '',
                    item.Contents__c || ''
                ]);
            });

            this.generateExcel(dataArray);

        } catch(error) {
            console.error('엑셀 생성 중 오류', error);
        } finally {
            this.isLoaded = false;
        }
    }

    generateExcel(dataArray) {
        try {
            const wb = XLSX.utils.book_new();
            const ws = XLSX.utils.aoa_to_sheet(dataArray);
            XLSX.utils.book_append_sheet(wb, ws, 'Meeting Log');
    
            const base64Content = XLSX.write(wb, { bookType: 'xlsx', type: 'buffer' });
            
            // const dataUri = 'data:application/vnd.openxmlformats-officedocument.spreadsheetml.sheet;base64,' + base64Content;
            const blob = new Blob([base64Content], {
                type: 'application/octet-stream'
            });

            const downloadEle = document.createElement('a');
            // downloadEle.style.display = 'none';
            // downloadEle.href = dataUri;
            const url = URL.createObjectURL(blob);
            downloadEle.href = url;

            const title = `MeetingLog_All_${this.dateStr}.xlsx`;
            downloadEle.download = title;
            // downloadEle.setAttribute('download', title);

            // 클릭 이벤트를 시뮬레이트하여 파일 다운로드 유도
            const clickEvent = new MouseEvent('click', {
                view: window,
                bubbles: true,
                cancelable: false
            });
            
            downloadEle.dispatchEvent(clickEvent);

            // 다운로드 완료 후 엘리먼트 제거
            downloadEle.remove();
            
            setTimeout(() => {
                document.body.removeChild(downloadEle);
            }, 100);
    
        } catch (e) {
            console.error('Base64 변환 중 에러', e);
            alert('엑셀 생성 실패: ' + e.message);
        }
    }
}