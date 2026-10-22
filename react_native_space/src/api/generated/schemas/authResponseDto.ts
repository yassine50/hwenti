// @ts-nocheck
import type { AuthUserDto } from './authUserDto';

export interface AuthResponseDto {
  token: string;
  user: AuthUserDto;
}
