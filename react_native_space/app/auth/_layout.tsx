import { Stack, Redirect } from 'expo-router';
import { useAuth } from '@/src/contexts/AuthContext';
import { LoadingScreen } from '@/src/components/LoadingScreen';

export default function AuthLayout() {
  const { isLoading, isAuthenticated } = useAuth();
  if (isLoading) return <LoadingScreen />;
  if (isAuthenticated) return <Redirect href="/tabs" />;
  return <Stack screenOptions={{ headerShown: false }} />;
}
