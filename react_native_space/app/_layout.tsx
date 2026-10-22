import React from 'react';
import { Stack } from 'expo-router';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { PaperProvider } from 'react-native-paper';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { LocaleProvider } from '@/src/contexts/LocaleContext';
import { AuthProvider } from '@/src/contexts/AuthContext';
import { FilterProvider } from '@/src/contexts/FilterContext';
import { ErrorBoundary } from '@/src/components/ErrorBoundary';

const queryClient = new QueryClient();

export default function RootLayout() {
  return (
    <ErrorBoundary>
      <QueryClientProvider client={queryClient}>
        <SafeAreaProvider>
          <PaperProvider>
            <LocaleProvider>
              <AuthProvider>
                <FilterProvider>
                  <Stack screenOptions={{ headerShown: false }} />
                </FilterProvider>
              </AuthProvider>
            </LocaleProvider>
          </PaperProvider>
        </SafeAreaProvider>
      </QueryClientProvider>
    </ErrorBoundary>
  );
}
