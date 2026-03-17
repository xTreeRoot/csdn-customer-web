<template>
  <div class="use-code-page">
    <div class="page-header">
      <h1 class="page-title">资源下载</h1>
      <p class="page-subtitle">使用访问码下载会员文章</p>
    </div>
    
    <div class="form-container">
      <form @submit.prevent="handleSubmit">
        <div class="form-group">
          <label class="form-label">访问码</label>
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
          {{ loading ? '下载中...' : '使用Code' }}
        </button>
      </form>
      
      <div v-if="result.filePath" class="result-section">
        <div class="result-title">下载成功！</div>
        
        <div class="result-actions">
          <button 
            @click="handleOpenHtml" 
            class="action-btn primary-btn"
          >
            打开HTML
          </button>
          
          <button 
            @click="handleDownload" 
            class="action-btn success-btn"
          >
            下载压缩包
          </button>
        </div>

      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed } from 'vue'
import { timeoutFetch } from '../utils/request'

interface FormData {
  code: string
  url: string
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
const result = reactive<Result>({
  filePath: '',
  message: ''
})

const filePath = computed(() => result.filePath)

const isFormValid = computed(() => {
  return formData.code.trim().length > 0 
    && formData.url.trim().length > 0
    && /^https?:\/\/.+csdn\.net\/.+/.test(formData.url.trim())
})

const handleSubmit = async () => {
  if (!isFormValid.value) {
    error.value = '请填写完整的访问码和有效的文章链接'
    return
  }
  
  try {
    loading.value = true
    error.value = ''
    result.filePath = ''
    result.message = ''
    
    const response = await timeoutFetch('/api/codes/use', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        code: formData.code.trim(),
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
      throw new Error('Code使用失败,请联系客服')
    }
    
    result.filePath = data.data || data
    result.message = 'Code使用成功！'
    
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
    a.download = `article_${Date.now()}.zip`
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
</style>
