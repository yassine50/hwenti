import { IsString, IsBoolean, IsOptional, IsInt } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class PresignedUploadDto {
  @IsString()
  fileName: string;

  @IsString()
  contentType: string;

  @IsBoolean()
  @IsOptional()
  isPublic?: boolean;
}

export class CompleteUploadDto {
  @IsString()
  cloud_storage_path: string;

  @IsString()
  fileName: string;

  @IsString()
  contentType: string;

  @IsInt()
  @IsOptional()
  fileSize?: number;
}

export class PresignedUploadResponseDto {
  @ApiProperty()
  uploadUrl: string;

  @ApiProperty()
  cloud_storage_path: string;
}

export class CompleteUploadResponseDto {
  @ApiProperty()
  id: string;

  @ApiProperty()
  cloud_storage_path: string;

  @ApiProperty()
  fileName: string;
}

export class FileUrlResponseDto {
  @ApiProperty()
  url: string;
}

export class DeleteFileResponseDto {
  @ApiProperty()
  success: boolean;
}
