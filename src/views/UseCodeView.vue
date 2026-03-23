<template>
  <div class="use-code-page">
    <div class="page-header">
      <h1 class="page-title">资源下载</h1>
      <p class="page-subtitle">使用访问码下载会员资源</p>
    </div>
    
    <div class="form-container">
      <form @submit.prevent="handleSubmit">
        <div class="form-group">
          <label class="form-label">访问码</label>
          <div class="input-with-action">
            <input 
              v-model="formData.code" 
              class="form-input" 
              type="text"
              placeholder="请输入访问码"
              maxlength="50"
              :disabled="loading"
            />
            <span class="char-count">{{ formData.code.length }}/50</span>
          </div>
        </div>
        
        <div v-if="codeInfo" class="code-info-section">
          <div class="info-title">访问码信息</div>
          <div class="info-grid">
            <div class="info-item">
              <span class="info-label">使用类型：</span>
              <span class="info-value">{{ codeInfo.usageTypeDescription }}</span>
            </div>
            <div class="info-item">
              <span class="info-label">状态：</span>
              <span class="info-value status" :class="getStatusClass(codeInfo.status)">{{ codeInfo.statusDescription }}</span>
            </div>
            <div v-if="codeInfo.remainingCount !== null" class="info-item">
              <span class="info-label">剩余次数：</span>
              <span class="info-value">{{ codeInfo.remainingCount }}/{{ codeInfo.maxUsageCount }}</span>
            </div>
            <div v-if="codeInfo.validDays" class="info-item">
              <span class="info-label">有效天数：</span>
              <span class="info-value">{{ codeInfo.validDays }}天</span>
            </div>
            <div v-if="codeInfo.validTo" class="info-item">
              <span class="info-label">到期时间：</span>
              <span class="info-value">{{ formatDate(codeInfo.validTo) }}</span>
            </div>
          </div>
        </div>
        
        <div class="form-group">
          <label class="form-label">资源链接</label>
          <textarea 
            v-model="formData.url" 
            class="form-textarea"
            placeholder="请输入资源链接"
            rows="4"
            maxlength="500"
            :disabled="loading"
          />
          <span class="char-count">{{ formData.url.length }}/500</span>
        </div>
        
        <div v-if="error" class="error-message">
          {{ error }}
        </div>
        
        <button 
          type="submit" 
          class="submit-btn" 
          :disabled="loading || !isFormValid"
          :class="{ 'loading': loading }"
        >
          <span v-if="loading" class="loading-spinner"></span>
          {{ loading ? '下载中...' : getButtonText() }}
        </button>
      </form>
      
      <div v-if="result.filePath" class="result-section">
        <div class="result-title">下载成功！</div>
        
        <div class="result-actions">
          <button 
            v-if="!isVipFileType"
            @click="handleOpenHtml" 
            class="action-btn primary-btn"
          >
            打开HTML
          </button>
          
          <button 
            @click="handleDownload" 
            class="action-btn success-btn"
          >
            {{ isVipFileType ? '下载文件' : '下载压缩包' }}
          </button>
        </div>

      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import {computed, reactive, ref} from 'vue'
import {timeoutFetch} from '../utils/request'

interface FormData {
  code: string
  url: string
}

interface CodeInfo {
  codeType: string
  codeTypeDescription: string
  usageType: string
  usageTypeDescription: string
  status: number
  statusDescription: string
  maxUsageCount: number | null
  usedCount: number
  remainingCount: number | null
  validDays: number | null
  validFrom: string | null
  validTo: string | null
  createTime: string
}

interface Result {
  filePath: string
  message: string
}

const formData = reactive<FormData>({
  code: '',
  url: ''
})

const loading = ref(false)
const error = ref('')
const codeInfo = ref<CodeInfo | null>(null)
const result = reactive<Result>({
  filePath: '',
  message: ''
})

const filePath = computed(() => result.filePath)

const isVipFileType = computed(() => {
  return codeInfo.value?.usageType === 'vip_file'
})

const isFormValid = computed(() => {
  return formData.code.trim().length > 0 
    && formData.url.trim().length > 0
    && /^https?:\/\/.+csdn\.net\/.+/.test(formData.url.trim())
})

const getButtonText = () => {
  if (isVipFileType.value) {
    return '开始下载'
  }
  return '使用Code'
}

const getStatusClass = (status: number) => {
  const statusMap: Record<number, string> = {
    1: 'status-active',
    0: 'status-banned',
    '-1': 'status-expired',
    '-2': 'status-depleted',
    2: 'status-deleted'
  }
  return statusMap[status] || 'status-default'
}

const formatDate = (dateStr: string) => {
  if (!dateStr) return ''
  const date = new Date(dateStr)
  const year = date.getFullYear()
  const month = String(date.getMonth() + 1).padStart(2, '0')
  const day = String(date.getDate()).padStart(2, '0')
  const hours = String(date.getHours()).padStart(2, '0')
  const minutes = String(date.getMinutes()).padStart(2, '0')
  const seconds = String(date.getSeconds()).padStart(2, '0')
  return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`
}

const handleCheckCode = async () => {
  const code = formData.code.trim()
  if (!code) {
    codeInfo.value = null
    return
  }

  try {
    const response = await timeoutFetch(`/api/codes/info?code=${encodeURIComponent(code)}`)
    
    if (!response.ok) {
      const errorData = await response.json()
      throw new Error(errorData.message || '查询Code信息失败')
    }
    
    const data = await response.json()
    
    if (data.code !== 200) {
      throw new Error(data.message || '查询Code信息失败')
    }
    
    codeInfo.value = data.data
    
  } catch (err: any) {
    codeInfo.value = null
    error.value = err.message || '查询Code信息失败'
    setTimeout(() => {
      error.value = ''
    }, 3000)
  }
}

const handleSubmit = async () => {
  if (!isFormValid.value) {
    error.value = '请填写完整的访问码和有效的资源链接'
    return
  }
  
  try {
    loading.value = true
    error.value = ''
    result.filePath = ''
    result.message = ''
    
    const code = formData.code.trim()
    
    const infoResponse = await timeoutFetch(`/api/codes/info?code=${encodeURIComponent(code)}`)
    if (!infoResponse.ok) {
      const errorData = await infoResponse.json()
      throw new Error(errorData.message || '查询Code信息失败')
    }
    const infoData = await infoResponse.json()
    if (infoData.code !== 200) {
      throw new Error(infoData.message || '查询Code信息失败')
    }
    codeInfo.value = infoData.data
    
    const response = await timeoutFetch('/api/codes/use', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        code: code,
        targetUrl: formData.url.trim(),
        userId: null
      })
    })
    
    if (!response.ok) {
      const errorData = await response.json()
      throw new Error(errorData.message || '请求失败')
    }
    
    const data = await response.json()
    
    if (data.code !== 200) {
      throw new Error('Code使用失败,请联系客服'+data.message)
    }
    
    result.filePath = data.data || data
    result.message = 'Code使用成功！'
    
    const refreshInfoResponse = await timeoutFetch(`/api/codes/info?code=${encodeURIComponent(code)}`)
    if (refreshInfoResponse.ok) {
      const refreshData = await refreshInfoResponse.json()
      if (refreshData.code === 200) {
        codeInfo.value = refreshData.data
      }
    }
    
  } catch (err: any) {
    error.value = err.message || '网络错误，请稍后重试'
    console.error('使用Code失败:', err)
  } finally {
    loading.value = false
  }
}

const handleOpenHtml = () => {
  if (!filePath.value) {
    error.value = '请先使用Code'
    return
  }
  
  window.open(`/api/html-resource/view-by-path?filePath=${encodeURIComponent(filePath.value)}`, '_blank')
}

const handleDownload = async () => {
  if (!filePath.value) {
    error.value = '请先使用Code'
    return
  }
  
  try {
    const response = await timeoutFetch(`/api/html-resource/download?filePath=${encodeURIComponent(filePath.value)}`)
    
    if (!response.ok) {
      throw new Error('下载失败')
    }
    
    const blob = await response.blob()
    const url = window.URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = isVipFileType.value ? `file_${Date.now()}.zip` : `article_${Date.now()}.zip`
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
    window.URL.revokeObjectURL(url)
    
  } catch (err: any) {
    error.value = '下载失败: ' + (err.message || '未知错误')
    console.error('下载失败:', err)
  }
}
</script>

<style scoped>
.use-code-page {
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 20px;
}

.page-header {
  text-align: center;
  color: white;
  margin-bottom: 40px;
  margin-top: 40px;
}

.page-title {
  font-size: 32px;
  font-weight: 700;
  margin-bottom: 12px;
  
  @media (max-width: 768px) {
    font-size: 24px;
  }
}

.page-subtitle {
  font-size: 16px;
  opacity: 0.9;
  margin: 0;
  
  @media (max-width: 768px) {
    font-size: 14px;
  }
}

.form-container {
  width: 100%;
  max-width: 500px;
  background: white;
  border-radius: 16px;
  padding: 32px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  
  @media (max-width: 768px) {
    padding: 24px;
    border-radius: 12px;
    max-width: 100%;
  }
}

.form-group {
  margin-bottom: 24px;
  position: relative;
}

.form-label {
  display: block;
  font-size: 14px;
  font-weight: 600;
  color: #333;
  margin-bottom: 8px;
}

.form-input {
  width: 100%;
  padding: 14px 16px;
  font-size: 16px;
  border: 2px solid #e0e0e0;
  border-radius: 8px;
  transition: all 0.3s ease;
  outline: none;
  
  &:focus {
    border-color: #667eea;
    box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
  }
  
  &:disabled {
    background: #f5f5f5;
    cursor: not-allowed;
  }
  
  @media (max-width: 768px) {
    font-size: 16px;
    padding: 12px 14px;
  }
}

.form-textarea {
  width: 100%;
  padding: 14px 16px;
  font-size: 16px;
  border: 2px solid #e0e0e0;
  border-radius: 8px;
  transition: all 0.3s ease;
  outline: none;
  resize: vertical;
  font-family: inherit;
  
  &:focus {
    border-color: #667eea;
    box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
  }
  
  &:disabled {
    background: #f5f5f5;
    cursor: not-allowed;
  }
  
  @media (max-width: 768px) {
    font-size: 16px;
    padding: 12px 14px;
  }
}

.char-count {
  position: absolute;
  right: 12px;
  bottom: 12px;
  font-size: 12px;
  color: #999;
}

.error-message {
  background: #fee;
  color: #c33;
  padding: 12px 16px;
  border-radius: 8px;
  font-size: 14px;
  margin-bottom: 16px;
  border-left: 4px solid #c33;
}

.submit-btn {
  width: 100%;
  padding: 16px 24px;
  font-size: 16px;
  font-weight: 600;
  color: white;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border: none;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s ease;
  
  &:hover:not(:disabled) {
    transform: translateY(-2px);
    box-shadow: 0 8px 20px rgba(102, 126, 234, 0.4);
  }
  
  &:disabled {
    background: #ccc;
    cursor: not-allowed;
    transform: none;
  }
  
  &.loading {
    opacity: 0.7;
    cursor: not-allowed;
  }
}

.loading-spinner {
  display: inline-block;
  width: 16px;
  height: 16px;
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-radius: 50%;
  border-top-color: white;
  animation: spin 0.8s linear infinite;
  margin-right: 8px;
  vertical-align: middle;
}

@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}

.result-section {
  margin-top: 32px;
  padding: 24px;
  background: #f8f9fa;
  border-radius: 12px;
  border: 1px solid #e9ecef;
}

.result-title {
  font-size: 18px;
  font-weight: 600;
  color: #28a745;
  margin-bottom: 20px;
  text-align: center;
  
  @media (max-width: 768px) {
    font-size: 16px;
  }
}

.result-actions {
  display: flex;
  flex-direction: row;
  gap: 12px;
  margin-bottom: 16px;
}

.action-btn {
  width: 100%;
  padding: 14px 20px;
  font-size: 16px;
  font-weight: 600;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s ease;
  
  &:active {
    transform: scale(0.98);
  }
}

.primary-btn {
  background: #667eea;
  color: white;
  
  &:hover {
    background: #5568d3;
  }
}

.success-btn {
  background: #28a745;
  color: white;
  
  &:hover {
    background: #218838;
  }
}

.result-info {
  padding: 12px;
  background: white;
  border-radius: 8px;
  font-size: 13px;
  color: #666;
  word-break: break-all;
}

.input-with-action {
  position: relative;
}

.code-info-section {
  margin-bottom: 24px;
  padding: 20px;
  background: #f8f9fa;
  border-radius: 12px;
  border: 1px solid #e9ecef;
}

.info-title {
  font-size: 16px;
  font-weight: 600;
  color: #333;
  margin-bottom: 16px;
}

.info-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 12px;
  
  @media (max-width: 768px) {
    grid-template-columns: 1fr;
  }
}

.info-item {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.info-label {
  font-size: 12px;
  color: #666;
  font-weight: 500;
}

.info-value {
  font-size: 14px;
  color: #333;
  font-weight: 600;
}

.info-value.status {
  display: inline-block;
  padding: 4px 12px;
  border-radius: 12px;
  font-size: 12px;
  font-weight: 500;
}

.status-active {
  background: #d4edda;
  color: #155724;
}

.status-banned {
  background: #f8d7da;
  color: #721c24;
}

.status-expired {
  background: #fff3cd;
  color: #856404;
}

.status-depleted {
  background: #e2e3e5;
  color: #383d41;
}

.status-deleted {
  background: #f8d7da;
  color: #721c24;
}

.status-default {
  background: #e2e3e5;
  color: #383d41;
}
</style>
