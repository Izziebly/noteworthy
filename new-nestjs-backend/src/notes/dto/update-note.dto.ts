import { IsString, IsOptional, MaxLength, MinLength } from 'class-validator';

export class UpdateNoteDto {
  @IsOptional()
  @IsString()
  @MinLength(1)
  @MaxLength(120)
  title?: string;

  @IsOptional()
  @IsString()
  @MinLength(1)
  content?: string;
}
