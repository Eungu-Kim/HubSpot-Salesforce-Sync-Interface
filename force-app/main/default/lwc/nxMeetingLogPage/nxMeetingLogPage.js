import { LightningElement, track, api } from 'lwc';
import getMeetingLogs from '@salesforce/apex/NX_MeetingLogPageController.getMeetingLogs';
import getMeetingLogBodies from '@salesforce/apex/NX_MeetingLogPageController.getMeetingLogBodies';

export default class NxMeetingLogPage extends LightningElement {

    @track meetingLogData = [];
    @track isLoading = false;
    @track isSearched = false;

    pageTitle = '회의록 목록';

    filterData = {};
    accountName = '';
    styleClassName = `nx-meeting-log-page-${Math.random().toString(36).slice(2, 10)}`;
    styleElementId = `nx-meeting-log-page-style-${Math.random().toString(36).slice(2, 10)}`;
    isCustomStyleApplied = false;

    get isHasData() {
        return this.meetingLogData && this.meetingLogData.length > 0;
    }

    get isSearchCheck() {
        return true;
    }

    get emptyRowColspan() {
        return 5;
    }

    @api
    getData(filter) {
        this.filterData = filter || {};
        this.searchHandleClick();
    }

    // 첫 로드시 자동 조회하지 않도록 connectedCallback 사용 안 함

    handleAccountNameChange(event) {
        this.accountName = event.target.value || '';
    }

    handleSearchClick() {
        this.searchHandleClick();
    }

    renderedCallback() {
        this.applyCustomStyle();
    }

    disconnectedCallback() {
        this.removeCustomStyle();
    }

    async searchHandleClick() {
        try {
            this.isLoading = true;
            this.isSearched = true;

            const result = await getMeetingLogs();
            // Account Name 필터 적용 (입력 없으면 전체)
            let filtered = result || [];
            const keyword = (this.accountName || '').trim().toLowerCase();
            if (keyword) {
                filtered = filtered.filter(item => {
                    const accName = item.SoldTo__r && item.SoldTo__r.Name ? item.SoldTo__r.Name.toLowerCase() : '';
                    return accName.includes(keyword);
                });
            }

            const externalIdList = filtered
                .map(item => item.IFExternalKey__c)
                .filter(id => !!id);
            const bodyMap = externalIdList.length > 0
                ? await getMeetingLogBodies({ idList: externalIdList })
                : {};

            this.meetingLogData = filtered.map(item => {
                const externalId = item.IFExternalKey__c;
                return {
                    id: item.Id,
                    title: item.Name,
                    task: item.Task__r ? item.Task__r.Name : '',
                    soldTo: item.SoldTo__r ? item.SoldTo__r.Name : '',
                    start: item.StartAllDay__c,
                    content: externalId && bodyMap[externalId] ? bodyMap[externalId] : (item.Contents__c || ''),
                    titleUrl: item.Id ? '/' + item.Id : '',
                    taskUrl: item.Task__c ? '/' + item.Task__c : '',
                    soldToUrl: item.SoldTo__c ? '/' + item.SoldTo__c : ''
                };
            });

        } catch(error) {
            console.error('조회 오류', error);
        } finally {
            this.isLoading = false;
        }
    }

    handleExcelDownload() {
        const child = this.template.querySelector('c-nx-download-meeting-log-excel');

        if (!child) {
            console.error('엑셀 컴포넌트 없음');
            return;
        }

        if (!this.meetingLogData || this.meetingLogData.length === 0) {
            alert('다운로드할 데이터가 없습니다.');
            return;
        }

        // 자식 LWC에 넘길 데이터 가공 (현재 화면에 표시된 데이터만)
        const excelData = this.meetingLogData.map(item => {
            return {
                Name: item.title || '',
                Task__c: item.task || '',
                SoldTo2__c: item.soldTo || '',
                StartAllDay__c: item.start || '',
                Contents__c: item.content || ''
            };
        });

        child.handleExcelDownloadList(null, excelData);
    }

    applyCustomStyle() {
        if (this.isCustomStyleApplied) {
            return;
        }

        const root = this.template.querySelector('.parent-box');
        if (!root) {
            return;
        }

        root.classList.add(this.styleClassName);

        const styleEl = document.createElement('style');
        styleEl.id = this.styleElementId;
        styleEl.textContent = customStyle.replaceAll('__SCOPE__', `.${this.styleClassName}`);
        document.head.appendChild(styleEl);

        this.isCustomStyleApplied = true;
    }

    removeCustomStyle() {
        const root = this.template.querySelector('.parent-box');
        if (root) {
            root.classList.remove(this.styleClassName);
        }

        const styleEl = document.getElementById(this.styleElementId);
        if (styleEl && styleEl.parentNode) {
            styleEl.parentNode.removeChild(styleEl);
        }

        this.isCustomStyleApplied = false;
    }
}

const customStyle = `
__SCOPE__ .bg-dark-gray {
    background-color: rgb(100, 100, 100);
}
__SCOPE__ .bg-purple {
    background-color: rgb(127, 16, 132);
}
__SCOPE__ .bg-light-purple {
    background-color: rgb(245, 234, 246);
}
__SCOPE__ .bg-yellow {
    background-color: rgb(190, 167, 143);
}
__SCOPE__ .bg-light-gray {
    background-color: #757474;
}
__SCOPE__ .bg-blue {
    background-color: rgb(0 32 96);
}
__SCOPE__ .font-white {
    color: #fff;
}

__SCOPE__ .parent-box {
    padding: 10px !important;
    background-color: #fff;
}

__SCOPE__ .table-wrap thead {
    position: sticky;
    top: 0;
    z-index: 1;
}

__SCOPE__ .table-wrap th,
__SCOPE__ .table-wrap td {
    text-align: center;
}

__SCOPE__ .card-form {
    padding-top: 18px;
    padding-bottom: 10px;
}
__SCOPE__ .card-form ul li {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 4px;
    margin-bottom: 2px;
}
__SCOPE__ .card-form ul li p {
    word-break: break-all;
}
__SCOPE__ .card-form ul li p:first-of-type {
    color: #757474;
}
__SCOPE__ .card-form ul li p:last-of-type {
    color: #181818;
}
__SCOPE__ .text-bold p {
    font-size: 18px;
    font-weight: 500;
}

@media all and (max-width: 768px) {
    __SCOPE__ .parent-box {
        padding: 0 !important;
    }
    __SCOPE__ .slds-col_bump-left > lightning-button {
        display: none;
    }
    __SCOPE__ .ul-card-body {
        border-bottom: 5px solid #ebe9e9;
        margin-bottom: 3px;
    }
    __SCOPE__ ul {
        border-top: 1px solid #000;
    }
    __SCOPE__ ul li:first-child {
        margin-top: 10px;
    }
    __SCOPE__ .card-form:last-of-type ul {
        border-bottom: 1px solid #000;
    }
}

__SCOPE__ .text-format {
    text-align: left;
}
__SCOPE__ .number-format {
    text-align: right;
}
__SCOPE__ .code-format {
    text-align: center;
}

__SCOPE__ .hidden-excel-component {
    display: none;
}

__SCOPE__ .search-area {
    margin-bottom: 8px;
}

__SCOPE__ .search-input-col {
    max-width: 320px;
    font-weight: bold;
    margin-bottom: 8px
}

__SCOPE__ .search-button-col {
    display: flex;
    align-items: center;
    margin-left: 5px;
    margin-top: 8px;
    margin-bottom: 0px;
}

__SCOPE__ lightning-button.search-button {
    --slds-c-button-brand-color-background: rgb(127, 16, 132);
    --slds-c-button-brand-color-border: rgb(127, 16, 132);

    --slds-c-button-brand-color-background-hover: rgb(100, 10, 105);
    --slds-c-button-brand-color-border-hover: rgb(127, 16, 132);
}

__SCOPE__ lightning-button.excel {
    --slds-c-button-text-color: rgb(127, 16, 132);
    --slds-c-button-neutral-text-color: rgb(127, 16, 132);
    --slds-c-button-text-color-hover: rgb(127, 16, 132);
}
`;