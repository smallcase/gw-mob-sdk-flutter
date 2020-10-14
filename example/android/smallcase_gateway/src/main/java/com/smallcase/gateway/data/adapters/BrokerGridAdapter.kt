package com.smallcase.gateway.data.adapters

import android.content.Context
import android.graphics.Color
import android.os.Handler
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.recyclerview.widget.RecyclerView

import coil.api.load
import com.smallcase.gateway.R
import com.smallcase.gateway.data.models.BrokerConfig
import com.smallcase.gateway.utils.convertDpToPixel


/**
*broker grid adapter shows name and icon of the respective broker in a grid view
 * */
class BrokerGridAdapter(
    private val brokerConfigs: List<BrokerConfig>,
    val clickListener :(BrokerConfig)-> Unit
) : RecyclerView.Adapter<BrokerGridAdapter.BrokerChooserViewHolder>() {

    private var selectedBrokerConfig: BrokerConfig? = null

    class BrokerChooserViewHolder(itemView:View):RecyclerView.ViewHolder(itemView)
    {
        val brokerName = itemView.findViewById<TextView>(R.id.row_tv_broker_item_name)
        val brokerImage = itemView.findViewById<ImageView>(R.id.row_iv_broker_item_icon)
        val parentContainer = itemView.findViewById<ConstraintLayout>(R.id.row_ll_broker_item_parent)
        val selectedImage = itemView.findViewById<ImageView>(R.id.iv_broker_item_selected)

    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): BrokerChooserViewHolder {
        return BrokerChooserViewHolder(LayoutInflater.from(parent.context).inflate(R.layout.row_broker_item,parent,false))
    }

    override fun getItemCount(): Int = brokerConfigs.size
    override fun onBindViewHolder(holder: BrokerChooserViewHolder, position: Int) {
        brokerConfigs[position].let { brokerConfig->
            if (selectedBrokerConfig==brokerConfig)
            {
                holder.parentContainer.setBackgroundColor(Color.parseColor("#44dde0e4"))
                holder.selectedImage.visibility = View.VISIBLE
                holder.brokerName.setTextColor(Color.parseColor("#1F7AE0"))
            } else
            {
                holder.brokerName.setTextColor(Color.parseColor("#535b62"))
                holder.selectedImage.visibility = View.GONE
            }

            holder.brokerName.text=brokerConfig.brokerShortName
            holder.brokerImage
                .load("https://assets.smallcase.com/smallcase/assets/brokerLogo/small/${brokerConfig.broker}.png") {
                    crossfade(true)
                }

            holder.itemView.setOnClickListener { clickListener(brokerConfig) }


        }

    }

    fun setSelected(brokerConfig: BrokerConfig)
    {
       selectedBrokerConfig = brokerConfig
        this.notifyDataSetChanged()
    }




}
