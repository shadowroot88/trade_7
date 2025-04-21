from freqtrade.strategy.interface import IStrategy
from pandas import DataFrame

class SampleStrategy(IStrategy):
    minimal_roi = {
        "0": 0.01
    }

    stoploss = -0.10
    timeframe = '5m'

    def populate_indicators(self, dataframe: DataFrame, metadata: dict) -> DataFrame:
        dataframe['ma10'] = dataframe['close'].rolling(window=10).mean()
        return dataframe

    def populate_buy_trend(self, dataframe: DataFrame, metadata: dict) -> DataFrame:
        dataframe.loc[
            (
                (dataframe['close'] > dataframe['ma10'])
            ),
            'buy'] = 1
        return dataframe

    def populate_sell_trend(self, dataframe: DataFrame, metadata: dict) -> DataFrame:
        dataframe.loc[
            (
                (dataframe['close'] < dataframe['ma10'])
            ),
            'sell'] = 1
        return dataframe