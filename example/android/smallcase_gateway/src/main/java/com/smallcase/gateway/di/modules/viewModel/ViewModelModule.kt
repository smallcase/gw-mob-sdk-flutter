package com.smallcase.gateway.di.modules.viewModel

import androidx.lifecycle.ViewModel
import com.smallcase.gateway.di.annotation.ViewModelKey
import com.smallcase.gateway.screens.connect.viewModel.ConnectActivityViewModel
import com.smallcase.gateway.screens.leadgen.viewModel.LeadGenViewModel
import com.smallcase.gateway.screens.transaction.viewModel.TransactionActivityViewModel
import dagger.Binds
import dagger.Module
import dagger.multibindings.IntoMap

@Module
internal abstract class ViewModelModule {

    @Binds
    @IntoMap
    @ViewModelKey(ConnectActivityViewModel::class)
    internal abstract fun bindConnectActivityViewModel(connectActivityViewModel: ConnectActivityViewModel):ViewModel

    @Binds
    @IntoMap
    @ViewModelKey(TransactionActivityViewModel::class)
    internal abstract fun bindTransactionActivitViewModule(transactionActivityViewModel: TransactionActivityViewModel):ViewModel

    @Binds
    @IntoMap
    @ViewModelKey(LeadGenViewModel::class)
    internal abstract fun bindLeadGenViewModel(leadGenViewModel: LeadGenViewModel):ViewModel


}