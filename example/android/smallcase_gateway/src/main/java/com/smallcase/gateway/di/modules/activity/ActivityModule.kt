package com.smallcase.gateway.di.modules.activity

import com.smallcase.gateway.screens.connect.activity.BrokerChooserActivity
import com.smallcase.gateway.screens.connect.activity.ConnectActivity
import com.smallcase.gateway.screens.connect.activity.ConnectedConsentActivity
import com.smallcase.gateway.screens.leadgen.activity.LeadGenActivity
import com.smallcase.gateway.screens.transaction.activity.TransactionProcessActivity
import dagger.Binds
import dagger.Module
import dagger.android.ContributesAndroidInjector
import dagger.multibindings.IntoMap

@Module
abstract class ActivityModule{


    @ContributesAndroidInjector
    internal abstract fun contributeConnectActivity():ConnectActivity

    @ContributesAndroidInjector
    internal abstract fun contributeBrokerChooserActivity():BrokerChooserActivity

    @ContributesAndroidInjector
    internal abstract fun contributeTransactionProcessActivity():TransactionProcessActivity

    @ContributesAndroidInjector
    internal abstract fun contributeConnectedConsentScreen():ConnectedConsentActivity

    @ContributesAndroidInjector
    internal abstract fun contributeLeadGenActivity():LeadGenActivity
}