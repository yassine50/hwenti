import { IsEmail, IsString, MinLength, IsIn } from 'class-validator';

export class SignupDto {
  @IsEmail()
  email: string;

  @IsString()
  @MinLength(8)
  password: string;

  @IsString()
  name: string;

  @IsIn(['merchant', 'visitor'])
  role: string;
}
