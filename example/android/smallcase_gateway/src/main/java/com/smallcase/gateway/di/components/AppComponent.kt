package com.smallcase.gateway.di.components

import com.smallcase.gateway.data.ConfigRepository
import com.smallcase.gateway.di.DaggerCustomWrapper.LibraryCore
import com.smallcase.gateway.di.modules.activity.ActivityModule
import com.smallcase.gateway.di.modules.fragment.FragmentModule
import com.smallcase.gateway.di.modules.network.BaseNetworkModule
import com.smallcase.gateway.di.modules.network.ConfigNetworkModule
import com.smallcase.gateway.di.modules.network.FakeNetworkModule
import com.smallcase.gateway.di.modules.network.GatewayNetworkModule
import com.smallcase.gateway.di.modules.viewModel.ViewModelModule
import com.smallcase.gateway.screens.connect.repo.GateWayRepo
import dagger.Component
import dagger.Provides
import dagger.android.AndroidInjectionModule
import dagger.android.AndroidInjector
import dagger.android.support.AndroidSupportInjection
import javax.inject.Singleton

@Singleton
@Component(modules = [(AndroidInjectionModule::class),(BaseNetworkModule::class),(ConfigNetworkModule::class),(GatewayNetworkModule::class),(ActivityModule::class),(ViewModelModule::class),(FragmentModule::class),(FakeNetworkModule::class)])
interface AppComponent  {


    @Component.Builder
    interface Builder{
        fun build():AppComponent
    }

    fun inject(libraryCore: LibraryCore)

}