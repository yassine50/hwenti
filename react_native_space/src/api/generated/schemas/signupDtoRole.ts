// @ts-nocheck

export type SignupDtoRole = typeof SignupDtoRole[keyof typeof SignupDtoRole];


export const SignupDtoRole = {
  merchant: 'merchant',
  visitor: 'visitor',
} as const;
