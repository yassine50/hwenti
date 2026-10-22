// @ts-nocheck
import type { MerchantSetupDtoTradeType } from './merchantSetupDtoTradeType';

export interface MerchantSetupDto {
  shopName: string;
  tradeType: MerchantSetupDtoTradeType;
  governorateId: string;
  delegationId: string;
  phone: string;
  logoFileId?: string;
}
