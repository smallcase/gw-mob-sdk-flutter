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

class OtherBrokerAdapter(private val otherBrokerList:List<BrokerConfig>,private val clickListener:(BrokerConfig)->Unit) : RecyclerView.Adapter<OtherBrokerAdapter.ViewHolder>(){
    class ViewHolder(itemView: View): RecyclerView.ViewHolder(itemView){
        val spinnerImage = itemView.findViewById<ImageView>(R.id.spinner_image)
        val spinnerText = itemView.findViewById<TextView>(R.id.spinner_text)
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        return ViewHolder(LayoutInflater.from(parent.context).inflate(R.layout.spinner_item,parent,false))
    }

    override fun getItemCount(): Int = otherBrokerList.size

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        otherBrokerList[position].also { otherBroker ->
            holder.spinnerImage.load("https://assets.smallcase.com/smallcase/assets/brokerLogo/small/${otherBroker.broker}.png") {
                crossfade(true)
            }
            holder.spinnerText.text = otherBroker.brokerShortName
            holder.itemView.setOnClickListener {
                clickListener(otherBroker)
            }
        }
    }
}