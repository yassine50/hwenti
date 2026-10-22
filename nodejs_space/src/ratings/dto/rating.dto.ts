import { IsInt, Min, Max } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateRatingDto {
  @IsInt()
  @Min(1)
  @Max(5)
  score: number;
}

export class RatingResponseDto {
  @ApiProperty()
  id: string;

  @ApiProperty()
  merchantId: string;

  @ApiProperty()
  score: number;

  @ApiProperty()
  createdAt: string;
}

export class RatingItemDto {
  @ApiProperty()
  id: string;

  @ApiProperty()
  score: number;

  @ApiProperty()
  userName: string;

  @ApiProperty()
  createdAt: string;
}

export class RatingListResponseDto {
  @ApiProperty({ type: () => [RatingItemDto] })
  items: RatingItemDto[];

  @ApiProperty()
  average: number;

  @ApiProperty()
  total: number;
}
