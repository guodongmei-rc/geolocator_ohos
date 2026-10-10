/*
 * Copyright (C) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import { EventChannel, FlutterPluginBinding } from "@ohos/flutter_ohos";
import { EventSink, StreamHandler } from '@ohos/flutter_ohos/src/main/ets/plugin/common/EventChannel';
import common from '@ohos.app.ability.common';
import { geoLocationManager } from '@kit.LocationKit';
import { BusinessError } from '@kit.BasicServicesKit';

// 定义服务状态枚举
enum ServiceStatus {
  disabled = 0,
  enabled = 1
}

export default class LocationServiceHandlerImpl implements StreamHandler {
  private channel: EventChannel | null = null;
  private context: common.UIAbilityContext | null = null;
  private eventSink: EventSink | null = null;
  private lastKnownServiceStatus: ServiceStatus | null = null;
  private statusCheckInterval: number | null = null;

  constructor() {

  }

  startListening(context: common.UIAbilityContext, binding: FlutterPluginBinding): void {
    if (this.channel != null) {
      this.stopListening();
    }
    this.channel = new EventChannel(binding.getBinaryMessenger(), 'flutter.baseflow.com/geolocator_service_updates');
    this.channel.setStreamHandler(this);
    this.context = context;
  }

  stopListening(): void {
    if (this.channel == null) {
      return;
    }
    console.debug(">>>>>>>>>>LocationServiceHandlerImpl=======stopListening")
    this.disposeListeners();
    this.channel.setStreamHandler(null);
    this.channel = null;
  }

  async onListen(args: object, events: EventSink): Promise<void> {
    if (this.context == null) {
      return;
    }

    this.eventSink = events;
    
    // 获取初始状态
    await this.checkLocationServiceStatus();
    
    // 开始定期检查定位服务状态（鸿蒙系统暂无直接的系统广播监听）
    this.startStatusMonitoring();
  }

  onCancel(args: object): void {
    this.disposeListeners();
  }

  private async checkLocationServiceStatus(): Promise<void> {
    try {
      const isEnabled = await geoLocationManager.isLocationEnabled();
      const currentStatus = isEnabled ? ServiceStatus.enabled : ServiceStatus.disabled;
      
      // 只有状态发生变化时才发送事件
      if (this.lastKnownServiceStatus === null || this.lastKnownServiceStatus !== currentStatus) {
        this.lastKnownServiceStatus = currentStatus;
        if (this.eventSink) {
          this.eventSink.success(currentStatus);
          console.debug(`>>>>>>>>>>LocationService status changed to: ${currentStatus === ServiceStatus.enabled ? 'enabled' : 'disabled'}`);
        }
      }
    } catch (error) {
      console.error('>>>>>>>>>>Error checking location service status:', JSON.stringify(error));
      if (this.eventSink) {
        this.eventSink.error('LOCATION_SERVICE_CHECK_ERROR', 'Failed to check location service status', error);
      }
    }
  }

  private startStatusMonitoring(): void {
    // 每2秒检查一次定位服务状态
    this.statusCheckInterval = setInterval(async () => {
      await this.checkLocationServiceStatus();
    }, 2000);
  }

  private disposeListeners(): void {
    if (this.statusCheckInterval !== null) {
      clearInterval(this.statusCheckInterval);
      this.statusCheckInterval = null;
    }
    this.eventSink = null;
    this.lastKnownServiceStatus = null;
  }
}