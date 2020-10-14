package com.smallcase.gateway.di.DaggerCustomWrapper

import com.smallcase.gateway.base.Session.SessionManager
import com.smallcase.gateway.data.ConfigRepository
import com.smallcase.gateway.di.components.DaggerAppComponent
import com.smallcase.gateway.screens.connect.repo.GateWayRepo
import dagger.android.AndroidInjector
import dagger.android.DispatchingAndroidInjector
import dagger.android.HasAndroidInjector
import javax.inject.Inject

class LibraryCore private constructor():HasAndroidInjector{

    init {
        beginInjection()
    }

    @Inject
    lateinit var dispatchingAndroidInjector: DispatchingAndroidInjector<Any>


    companion object{
        private var INSTANCE:LibraryCore?=null
        fun getInstance():LibraryCore
        {
            return INSTANCE?:LibraryCore().also { INSTANCE=it }
        }
    }


    @Inject
    lateinit var gateRepo:GateWayRepo

    @Inject
    lateinit var configRepo:ConfigRepository

    @Inject
    lateinit var sessionManager:SessionManager

    /*@Inject
    lateinit var fragmentInjector: DispatchingAndroidInjector<Fragment>*/



   // override fun supportFragmentInjector(): AndroidInjector<Fragment> = fragmentInjector

    private fun beginInjection()
    {
      DaggerAppComponent.builder().build().inject(this)



    }


    override fun androidInjector(): AndroidInjector<Any> = dispatchingAndroidInjector


}