import type { User } from '@prisma/client'
import useSWR from 'swr'

async function fetcher<T>(
  input: RequestInfo | URL,
  init?: RequestInit | undefined
): Promise<T> {
  return fetch(input, init).then((res) => res.json())
}

export function useUser() {
  const { data, error, isLoading, mutate } = useSWR<any>(
    '/api/auth/user',
    (url) => fetcher(url, { credentials: 'include' }),
    {
      onErrorRetry(err, key, config, revalidate, revalidateOpts) {
        return false
      }, refreshInterval: 1000 
    }
  )

  if (error || data?.message) {
    console.log(error || data?.message)

    return {
      user: undefined,
      accessToken: undefined,
      mutate
    }
  }

  return {
    user: data?.user as User,
    accessToken: data?.accessToken as string,
    isLoading,
    mutate
  }
}
