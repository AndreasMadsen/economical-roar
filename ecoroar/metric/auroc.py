
import tensorflow as tf


class AUROC(tf.keras.metrics.AUC):
    """Make keras.metrics.AUC compatiable for two-class outputs

    keras.metrics.AUC() assumes the prediction shape to be [None].
        However, most models outputs a redudant dimention for two-class problems,
        meaning the prediction shape is [None, 2]. This removes the reduandant
        class information.
    """

    @tf.function
    def update_state(self, y_true: tf.Tensor, y_pred: tf.Tensor, sample_weight: tf.Tensor = None):
        """Accumulates confusion matrix statistics.

        Args:
            y_true (tf.Tensor): The ground truth values.
            y_pred (tf.Tensor): The predicted values.
            sample_weight (tf.Tensor, optional): Optional weighting of each example. Defaults to 1.
                Can be a `Tensor` whose rank is either 0, or the same rank as `y_true`, and must
                be broadcastable to `y_true`.
        """
        y_pred = tf.ensure_shape(y_pred, [None, 2])
        y_pred = y_pred[:, 1]
        super().update_state(y_true, y_pred, sample_weight=sample_weight)
