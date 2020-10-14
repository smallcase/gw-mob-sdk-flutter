package com.smallcase.gateway.data.adapters

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import coil.api.load
import com.smallcase.gateway.R
import com.smallcase.gateway.data.models.BrokerConfig
import com.smallcase.gateway.data.models.tweetConfig.UpcomingBroker

class SearchBrokerAdapter(private val searchList:List<Any>, private val clickListener:(Any)->Unit) : RecyclerView.Adapter<SearchBrokerAdapter.ViewHolder>(){
    class ViewHolder(itemView: View): RecyclerView.ViewHolder(itemView){
        val spinnerImage = itemView.findViewById<ImageView>(R.id.spinner_image)
        val spinnerText = itemView.findViewById<TextView>(R.id.spinner_text)
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        return ViewHolder(LayoutInflater.from(parent.context).inflate(R.layout.spinner_item,parent,false))
    }

    override fun getItemCount(): Int = searchList.size

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        searchList[position].also { broker->
            if (broker is UpcomingBroker)
            {
                holder.spinnerImage.load("https://assets.smallcase.com/smallcase/assets/brokerLogo/small/${broker.broker}.png") {
                    crossfade(true)
                }
                holder.spinnerText.text = broker.brokerDisplayName
                holder.itemView.setOnClickListener {
                    clickListener(broker)
                }
            }else
            {
                broker as BrokerConfig
                holder.spinnerImage.load("https://assets.smallcase.com/smallcase/assets/brokerLogo/small/${broker.broker}.png") {
                    crossfade(true)
                }
                holder.spinnerText.text = broker.brokerShortName
                holder.itemView.setOnClickListener {
                    clickListener(broker)
                }
            }
        }

    }
}