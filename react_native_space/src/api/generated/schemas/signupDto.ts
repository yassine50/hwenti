// @ts-nocheck
import type { SignupDtoRole } from './signupDtoRole';

export interface SignupDto {
  email: string;
  /** @minLength 8 */
  password: string;
  name: string;
  role: SignupDtoRole;
}
