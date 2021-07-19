import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { take } from 'rxjs/operators';
import { AppConfig } from './app-config.interface';

@Injectable({
  providedIn: 'root'
})
export class AppConfigService {

  public config: Promise<AppConfig>;

  constructor(private httpClient: HttpClient) {
    this.config = this.httpClient.get<AppConfig>("/assets/config.json").pipe(take(1)).toPromise();
  }

  public async get(key: keyof AppConfig, defaultValue: string | number): Promise<string | number> {
    const conf = await this.config;
    return (conf[key]) ? conf[key] : defaultValue;
  }

}
