// @ts-nocheck
import type { FollowItemDto } from './followItemDto';

export interface FollowListResponseDto {
  items: FollowItemDto[];
  total: number;
  page: number;
  totalPages: number;
}
