// @ts-nocheck
import type { RatingItemDto } from './ratingItemDto';

export interface RatingListResponseDto {
  items: RatingItemDto[];
  average: number;
  total: number;
}
