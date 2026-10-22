// @ts-nocheck

export type CreateReportDtoReason = typeof CreateReportDtoReason[keyof typeof CreateReportDtoReason];


export const CreateReportDtoReason = {
  counterfeit: 'counterfeit',
  fraud: 'fraud',
  inappropriate: 'inappropriate',
  other: 'other',
} as const;
