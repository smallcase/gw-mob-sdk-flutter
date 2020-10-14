package com.smallcase.gateway.data.adapters

import android.graphics.Typeface
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import coil.api.load
import com.smallcase.gateway.R
import com.smallcase.gateway.data.models.tweetConfig.UpcomingBroker

class BrokerYetToComeAdapter(private val upcomingBrokerList:List<UpcomingBroker>,private val selectedBroker:UpcomingBroker?,private val selectedColor:Int,private val selectedTypeFace:Typeface?,val clickListener:(UpcomingBroker)->Unit) : RecyclerView.Adapter<BrokerYetToComeAdapter.ViewHolder>(){
    class ViewHolder(itemView:View):RecyclerView.ViewHolder(itemView){
      val spinnerImage = itemView.findViewById<ImageView>(R.id.spinner_image)
      val spinnerText = itemView.findViewById<TextView>(R.id.spinner_text)
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        return ViewHolder(LayoutInflater.from(parent.context).inflate(R.layout.spinner_item,parent,false))
    }

    override fun getItemCount(): Int = upcomingBrokerList.size

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
       upcomingBrokerList[position].also { upcomingBroker ->
          holder.spinnerImage.load("https://assets.smallcase.com/smallcase/assets/brokerLogo/small/${upcomingBroker.broker}.png") {
              crossfade(true)
          }
          holder.spinnerText.text = upcomingBroker.brokerDisplayName
           selectedBroker?.let { if (upcomingBroker==selectedBroker){
               holder.spinnerText.setTextColor(selectedColor)
               holder.spinnerText.typeface = selectedTypeFace
           } }
          holder.itemView.setOnClickListener {
              clickListener(upcomingBroker)
          }
       }
    }
}