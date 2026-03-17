const DEFAULT_TIMEOUT = 90000

function timeoutFetch(
  url: string,
  options: RequestInit = {},
  timeout: number = DEFAULT_TIMEOUT
): Promise<Response> {
  return new Promise((resolve, reject) => {
    const controller = new AbortController()
    const timeoutId = setTimeout(() => {
      controller.abort()
      reject(new Error(`请求超时，请稍后重试`))
    }, timeout)

    fetch(url, {
      ...options,
      signal: controller.signal
    })
      .then((response) => {
        clearTimeout(timeoutId)
        resolve(response)
      })
      .catch((error) => {
        clearTimeout(timeoutId)
        reject(error)
      })
  })
}

export { timeoutFetch }
