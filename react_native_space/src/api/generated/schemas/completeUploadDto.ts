// @ts-nocheck

export interface CompleteUploadDto {
  cloud_storage_path: string;
  fileName: string;
  contentType: string;
  fileSize?: number;
}
