import React, { createContext, useContext, useState, useEffect, useCallback } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';
import {
  authControllerLogin,
  authControllerSignup,
  authControllerMe,
} from '@/src/api/generated/api';
import { getErrorMessage } from '@/src/api/customFetch';
import type { AuthUserDto } from '@/src/api/generated/schemas';

interface AuthContextType {
  user: AuthUserDto | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  login: (email: string, password: string) => Promise<void>;
  signup: (email: string, password: string, name: string, role: string) => Promise<void>;
  logout: () => Promise<void>;
  refreshUser: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType>({
  user: null,
  isAuthenticated: false,
  isLoading: true,
  login: async () => {},
  signup: async () => {},
  logout: async () => {},
  refreshUser: async () => {},
});

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<AuthUserDto | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    (async () => {
      try {
        const token = await AsyncStorage.getItem('auth_token');
        if (token) {
          const res = await authControllerMe();
          setUser(res?.user ?? null);
        }
      } catch {
        await AsyncStorage.removeItem('auth_token').catch(() => {});
      } finally {
        setIsLoading(false);
      }
    })();
  }, []);

  const login = useCallback(async (email: string, password: string) => {
    try {
      const res = await authControllerLogin({ email, password });
      await AsyncStorage.setItem('auth_token', res?.token ?? '');
      setUser(res?.user ?? null);
    } catch (e) {
      throw new Error(getErrorMessage(e, 'Login failed'));
    }
  }, []);

  const signup = useCallback(async (email: string, password: string, name: string, role: string) => {
    try {
      const res = await authControllerSignup({ email, password, name, role: role as 'merchant' | 'visitor' });
      await AsyncStorage.setItem('auth_token', res?.token ?? '');
      setUser(res?.user ?? null);
    } catch (e) {
      throw new Error(getErrorMessage(e, 'Signup failed'));
    }
  }, []);

  const logout = useCallback(async () => {
    await AsyncStorage.removeItem('auth_token').catch(() => {});
    setUser(null);
  }, []);

  const refreshUser = useCallback(async () => {
    try {
      const res = await authControllerMe();
      setUser(res?.user ?? null);
    } catch {
      // ignore
    }
  }, []);

  return (
    <AuthContext.Provider value={{ user, isAuthenticated: !!user, isLoading, login, signup, logout, refreshUser }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  return useContext(AuthContext);
}
